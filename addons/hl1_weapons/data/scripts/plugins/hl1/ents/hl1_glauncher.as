class CScriptGrenadeLaunchedNPC : ScriptBase_Entity
{
	private CTerrorPlayer @pOwner;

	CScriptGrenadeLaunchedNPC()
	{
		@pOwner = null;
	}

	~CScriptGrenadeLaunchedNPC()
	{
		@pOwner = null;
	}

	void Precache()
	{
		Engine.PrecacheFile( model, "models/hl1/weapons/glauncher.mdl" );
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
		self.SetModel( "models/hl1/weapons/glauncher.mdl" );
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
		Explode();
	}

	bool HitPlayer( CBaseEntity @pHit )
	{
		if ( pHit is null ) return false;
		return pHit.IsPlayer();
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
		inputdata.Add( "damage", "100" );
		inputdata.Add( "range", "250" );
		inputdata.Add( "force", "0.0" );
		inputdata.Add( "killfeed", "hl1_glauncher" );
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