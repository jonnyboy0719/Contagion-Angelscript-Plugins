class CHL1ClassicExplode : ScriptBase_Entity
{
	private CTerrorPlayer @pOwner;
	private int m_iDamageRange = 200;
	private int m_iDamage = 150;
	private double m_dDamageForce = 0.0;
	private string m_szKillFeed = "hl1_classic_explode";

	private bool KeyValue( const string& in szKeyName, const string& in szValue )
	{
		if ( Utils.StrEql( "damage", szKeyName ) )
		{
			m_iDamage = parseInt( szValue );
			return true;
		}
		else if ( Utils.StrEql( "range", szKeyName ) )
		{
			m_iDamageRange = parseInt( szValue );
			return true;
		}
		else if ( Utils.StrEql( "force", szKeyName ) )
		{
			m_dDamageForce = parseFloat( szValue );
			return true;
		}
		else if ( Utils.StrEql( "killfeed", szKeyName ) )
		{
			m_szKillFeed = szValue;
			return true;
		}
		return false;
	}

	private bool AcceptInput( const string& in szInput, const string& in szValue, CBaseEntity@ pActivator, CBaseEntity@ pCaller )
	{
		// Explode time!
		if ( Utils.StrEql( "Explode", szInput ) )
		{
			Explode();
			return true;
		}
		return false;
	}

	void SetOwner( CTerrorPlayer@ pTerror )
	{
		@pOwner = pTerror;
	}

	void Explode()
	{
		// Our input
		CEntityData@ inputdata = EntityCreator::EntityData();
		inputdata.Add( "iMagnitude", formatInt( m_iDamage ) );
		inputdata.Add( "iRadiusOverride", formatInt( m_iDamageRange ) );
		inputdata.Add( "DamageForce", formatFloat( m_dDamageForce ) );
		inputdata.Add( "fireballsprite", "sprites/gexplo.vmt" );

		int flag_nodamage = 0x00000001;		// No Damage (because we do our own radius damage)
		int flag_nosmoke = 0x00000008;		// No smoke
		int flag_nospark = 0x00000020;		// Don't create any sparks
		//int flag_noballsmoke = 0x0100;		// No fireball smoke
		int flag_nosound = 0x00000040;		// Play our own sound
		int flag_nodlight = 0x00000400;		// No dynamic light
		int flag_classic = 0x00010000;		// Don't override the flags, we want the classic BOOM!
		inputdata.Add( "spawnflags", formatInt( flag_nodlight | flag_nosound | flag_classic | flag_nosmoke | flag_nospark | flag_nodamage ) );

		CBaseEntity @pExplode = EntityCreator::Create( "env_explosion", self.GetAbsOrigin(), self.GetAbsAngles(), inputdata );
		Engine.Ent_Fire_Ent( pExplode, "Explode" );

		DoRadiusDamage();
	}

	void DoRadiusDamage()
	{
		int	iRadius = ( m_iDamageRange > 0 ) ? m_iDamageRange : int( m_iDamage * 2.5f );

		CTakeDamageInfo info;
		info.SetInflictor( BaseClass );
		info.SetAttacker( pOwner );
		info.SetDamageType( DMG_BLAST );
		info.SetDamage( m_iDamage );

		if ( m_dDamageForce > 0.0 )
		{
			// Not the right direction, but it'll be fixed up by RadiusDamage.
			info.SetDamagePosition( self.GetAbsOrigin() );
			info.SetDamageForce( Vector( m_dDamageForce, 0, 0 ) );
		}

		// Our kill feed icon
		//self.SetClassname( m_szKillFeed );
		info.SetFakeWeapon( m_szKillFeed );

		// Do the radius damage
		Utils.RadiusDamage( info, self.GetAbsOrigin(), iRadius );

		// Delete after doing the radius damage
		self.SetThink( "KillSelf" );
		self.SetNextThink( Globals.GetCurrentTime() + 0.3 );
	}

	private void KillSelf()
	{
		self.SUB_Remove();
	}
}