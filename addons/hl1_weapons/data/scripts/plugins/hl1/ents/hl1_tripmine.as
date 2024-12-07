class CScriptTripMineNPC : ScriptBase_Entity
{
	private Vector m_vecDir;
	private Vector m_vecEnd;
	private float m_flPowerUp;
	private float m_flBeamLength;
	private CBaseEntity @pBeam;
	private CTerrorPlayer @pOwner;

	CScriptTripMineNPC()
	{
		m_vecDir.Zero();
		m_vecEnd.Zero();
		@pBeam = null;
		@pOwner = null;
	}

	~CScriptTripMineNPC()
	{
		if ( pBeam !is null )
			pBeam.SUB_Remove();
		@pBeam = null;
		@pOwner = null;
	}

	void SetTripmineOwner( CTerrorPlayer @pPlayer )
	{
		@pOwner = pPlayer;
	}

	void Precache()
	{
		Engine.PrecacheFile( model, "models/hl1/weapons/tripmine.mdl" );
	}

	void Spawn()
	{
		Precache();
		self.SetMoveType( MOVETYPE_FLY );
		self.SetSolidFlags( SOLID_BBOX );
		self.SetModel( "models/hl1/weapons/tripmine.mdl" );
		self.SetCycle( 0.0f );

		self.CreatePhysics( SOLID_BBOX, self.GetSolidFlags() | FSOLID_TRIGGER, true );
		self.SetCollisionGroup( COLLISION_GROUP_WEAPON );

		self.SetSize( Vector( -4, -4, -2), Vector(4, 4, 2) );

		self.SetThink( "PowerupThink" );
		self.SetNextThink( Globals.GetCurrentTime() + 0.2 );

		m_flPowerUp = Globals.GetCurrentTime() + 2.0f;

		self.SetHealth( 1 );

		self.m_takedamage = DAMAGE_YES;

		Engine.EmitSoundEntity( BaseClass, "Weapon_Tripmine_Place" );

		self.AddEffects( EF_NOSHADOW );
	}

	void PowerupThink()
	{
		if ( Globals.GetCurrentTime() > m_flPowerUp )
		{
			MakeBeam();
			self.RemoveSolidFlags( FSOLID_NOT_SOLID );
			// play enabled sound
			Engine.EmitSoundEntity( BaseClass, "Weapon_Tripmine_Activate" );
			return;
		}
		self.SetNextThink( Globals.GetCurrentTime() + 0.1f );
	}

	bool HitPlayer( CBaseEntity @pHit )
	{
		if ( pHit is null ) return false;
		return pHit.IsPlayer();
	}

	void MakeBeam()
	{
		// Tripmine sits at 90 on wall so rotate back to get m_vecDir
		QAngle angles = self.GetAbsAngles();
		angles.x -= 90;
		Globals.AngleVectors( angles, m_vecDir );

		m_vecEnd = self.GetAbsOrigin() + m_vecDir * 2048;

		CGameTrace tr;

		Utils.TraceLine( self.GetAbsOrigin(), m_vecEnd, MASK_SHOT, BaseClass, COLLISION_GROUP_NONE, tr );

		// The beam length
		m_flBeamLength = tr.fraction;

		// Draw length is not the beam length if entity is in the way
		float drawLength = tr.fraction;

		// If I hit a living thing, send the beam through me so it turns on briefly
		// and then blows the living thing up
		if ( HitPlayer( tr.m_pEnt ) )
		{
			//self.SetOwner( tr.m_pEnt );
			Utils.TraceLine( self.GetAbsOrigin(), m_vecEnd, MASK_SHOT, BaseClass, COLLISION_GROUP_NONE, tr );
			m_flBeamLength = tr.fraction;
			//self.SetOwner( null );
		}

		// set to follow laser spot
		self.SetThink( "BeamBreakThink" );

		// Delay first think slightly so beam has time
		// to appear if person right in front of it
		self.SetNextThink( Globals.GetCurrentTime() + 1.0f );

		// Create the beam
		Vector vecTmpEnd = self.GetLocalOrigin() + m_vecDir * 2048 * drawLength;
		@pBeam = Utils.CreateBeam( BaseClass, "sprites/laserbeam.vmt", "beam_attach", vecTmpEnd, Color( 0, 214, 198 ), 0.35, 25.6, 64 );
	}

	void BeamBreakThink()
	{
		CGameTrace tr;

		// NOT MASK_SHOT because we want only simple hit boxes
		Utils.TraceLine( self.GetAbsOrigin(), m_vecEnd, MASK_SOLID, BaseClass, COLLISION_GROUP_NONE, tr );

		if ( HitPlayer( tr.m_pEnt ) || abs( m_flBeamLength - tr.fraction ) > 0.001)
		{
			Explode();
			return;
		}

		self.SetNextThink( Globals.GetCurrentTime() + 0.05f );
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
		if ( pBeam !is null )
			pBeam.SUB_Remove();
		@pBeam = null;

		// Our input
		CEntityData@ inputdata = EntityCreator::EntityData();
		inputdata.Add( "damage", "150" );
		inputdata.Add( "range", "200" );
		inputdata.Add( "force", "0.0" );
		inputdata.Add( "killfeed", "hl1_tripmine" );
		inputdata.Add( "spawnflags", "0" );

		// Explode!
		Engine.EmitSoundEntity( BaseClass, "Weapon_HL1_Explode" );
		CBaseEntity @pEnt = EntityCreator::Create( "hl1_classic_explode", self.GetAbsOrigin() + m_vecDir * 8, self.GetAbsAngles(), inputdata );
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