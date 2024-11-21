namespace RTD
{
	class CPerkTurtleHeavenEnt : ScriptBase_Entity
	{
		CPerkTurtleHeavenEnt()
		{
		}

		~CPerkTurtleHeavenEnt()
		{
		}

		void Precache()
		{
			Engine.PrecacheFile( model, "models/props_laststop/turtle.mdl" );
		}

		void Setup( Vector vecVelocity )
		{
			self.SetAbsVelocity( vecVelocity );
			self.SetLocalAngularVelocity( Globals.RandomAngle( -400, 400 ) );
			self.SetMoveType( MOVETYPE_FLYGRAVITY );
		}

		void Spawn()
		{
			Precache();
			self.SetMoveType( MOVETYPE_FLY );
			self.SetSolidFlags( SOLID_BBOX );
			self.SetModel( "models/props_laststop/turtle.mdl" );
			self.SetCycle( 0.0f );

			self.CreatePhysics( SOLID_BBOX, self.GetSolidFlags() | FSOLID_TRIGGER, true );
			self.SetCollisionGroup( COLLISION_GROUP_WEAPON );

			self.SetSize( Vector( -4, -4, -2), Vector(4, 4, 2) );

			self.SetTouch( "OnGrenadeTouched" );

			PlayTurtleNoise();

			self.SetHealth( 1 );

			self.m_takedamage = DAMAGE_YES;

			self.AddEffects( EF_NOSHADOW );
		}

		void OnGrenadeTouched( CBaseEntity @pOther )
		{
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

		void PlayTurtleNoise()
		{
			array<int> collector = Utils.CollectPlayers();
			if ( collector.length() > 0 )
			{
				// Go trough our collector
				CTerrorPlayer@ pTerror = null;
				for ( uint i = 0; i < collector.length(); i++ )
				{
					@pTerror = ToTerrorPlayer( collector[ i ] );
					pTerror.PlayWwiseSound( "Secret_Turtle", self.entindex(), -1 );
				}
			}
		}

		void Explode()
		{
			self.SetHealth( 0 );
			PlayTurtleNoise();
			self.SUB_Remove();
		}
	}
}