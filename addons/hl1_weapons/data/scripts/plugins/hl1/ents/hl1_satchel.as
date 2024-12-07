class CScriptSatchelThrownNPC : ScriptBase_Entity
{
	private CTerrorPlayer @pOwner;
	private bool m_bPlayedBounce;

	CScriptSatchelThrownNPC()
	{
		@pOwner = null;
		m_bPlayedBounce = false;
	}

	~CScriptSatchelThrownNPC()
	{
		@pOwner = null;
	}

	void Precache()
	{
		Engine.PrecacheFile( model, "models/hl1/weapons/w_satchel_thrown.mdl" );
	}

	bool OwnSatchel( CTerrorPlayer @pTerror )
	{
		if ( pTerror is null ) return false;
		if ( pOwner is null )
		{
			// Our owner no longer exist, just delete this
			self.SUB_Remove();
			return false;
		}
		if ( pTerror.entindex() != pOwner.entindex() ) return false;
		return true;
	}

	void Setup( CTerrorPlayer @pPlayer, Vector vecVelocity )
	{
		@pOwner = pPlayer;
		self.SetAbsVelocity( vecVelocity );
		self.SetLocalAngularVelocity( Globals.RandomAngle( -400, 400 ) );
		self.SetMoveType( MOVETYPE_FLYGRAVITY );
	}

	void Spawn()
	{
		Precache();
		self.SetMoveType( MOVETYPE_FLY );
		self.SetSolidFlags( SOLID_BBOX );
		self.SetModel( "models/hl1/weapons/w_satchel_thrown.mdl" );
		self.SetCycle( 0.0f );

		self.CreatePhysics( SOLID_BBOX, self.GetSolidFlags() | FSOLID_TRIGGER, true );
		self.SetCollisionGroup( COLLISION_GROUP_WEAPON );

		self.SetSize( Vector( -4, -4, -2), Vector(4, 4, 2) );

		self.SetTouch( "OnGrenadeTouched" );

		self.SetHealth( 1 );

		self.m_takedamage = DAMAGE_YES;

		self.AddEffects( EF_NOSHADOW );
	}

	void OnGrenadeTouched( CBaseEntity @pOther )
	{
		// Ignore the person who threw this
		if ( pOther.entindex() == pOwner.entindex() ) return;

		CGameTrace tr;
		Utils.TraceLine( self.GetAbsOrigin(), self.GetAbsOrigin() - Vector( 0, 0, 10 ), MASK_SOLID, BaseClass, COLLISION_GROUP_NONE, tr );

		if ( tr.fraction < 1.0 )
		{
			// add a bit of static friction
			self.SetAbsVelocity( self.GetAbsVelocity() * 0.95 );
			self.SetLocalAngularVelocity( self.GetLocalAngularVelocity() * 0.9 );
		}

		if ( !self.IsGrounded() && self.GetAbsVelocity().Length2D() > 10 )
		{
			if ( tr.m_pEnt !is null )
			{
				if ( !m_bPlayedBounce )
					Engine.EmitSoundEntity( BaseClass, "Weapon_HL1_SatchelBounce" );
				m_bPlayedBounce = true;
			}
			else
				m_bPlayedBounce = false;
		}
	}

	int OnTakeDamage( const CTakeDamageInfo& in info )
	{
		if ( self.GetHealth() > 0 )
			Explode();
		return 0;
	}

	void Explode()
	{
		self.SetHealth( 0 );

		// Our input
		CEntityData@ inputdata = EntityCreator::EntityData();
		inputdata.Add( "damage", "200" );
		inputdata.Add( "range", "250" );
		inputdata.Add( "force", "0.0" );
		inputdata.Add( "killfeed", "hl1_satchel" );
		inputdata.Add( "spawnflags", "0" );

		// Explode!
		Engine.EmitSoundEntity( BaseClass, "Weapon_HL1_Explode" );
		CBaseEntity @pEnt = EntityCreator::Create( "hl1_classic_explode", self.GetAbsOrigin(), self.GetAbsAngles(), inputdata );
		ICustomEntity @IEnt = CustomEnts::Cast( pEnt );
		CHL1ClassicExplode @pExplode = cast<CHL1ClassicExplode>( IEnt );
		if ( pExplode !is null )
		{
			pExplode.SetOwner( pOwner );
			Engine.Ent_Fire_Ent( pEnt, "Explode" );
		}

		self.SUB_Remove();
	}
}