namespace RTD
{
	namespace Rocket
	{
		void Explode( int client )
		{
			CTerrorPlayer@ pPlayer = ToTerrorPlayer( client );
			if ( pPlayer is null ) return;
			if ( !pPlayer.IsAlive() ) return;
			Utils.SpawnGrenade( pPlayer, pPlayer.GetAbsOrigin(), Vector( 0, 0, 0 ), pPlayer.GetAbsAngles(), 0.1f );
			pPlayer.TakeDamage( CTakeDamageInfo( pPlayer, pPlayer.GetHealth(), DMG_SLASH ) );
		}

		void DeleteParticle( int client )
		{
			CBaseEntity@ pParticle = FindEntityByEntIndex( client );
			if ( pParticle is null ) return;
			pParticle.SUB_Remove();
		}

		void AttachParticle( CTerrorPlayer@ pPlayer, const string &in szParticle, const float &in flTime )
		{
			string target_name = "target" + formatInt( pPlayer.entindex() );
			pPlayer.SetEntityName( target_name );

			CEntityData@ inputdata = EntityCreator::EntityData();
			inputdata.Add( "effect_name", szParticle );
			CBaseEntity@ pParticle = EntityCreator::Create( "info_particle_system", pPlayer.GetAbsOrigin() + Vector( 0, 0, 60 ), pPlayer.EyeAngles(), inputdata );
			if ( pParticle is null ) return;
			Engine.Ent_Fire_Ent( pParticle, "SetParent", target_name );
			Engine.Ent_Fire_Ent( pParticle, "Start" );
			Schedule::Task( flTime, pParticle.entindex(), RTD::Rocket::DeleteParticle );
		}
	}

	class CPerkRocket : IRollTheDiceTypeBase
	{
		CPerkRocket()
		{
			m_ID = "rocket";
			m_Name = "Rocket Science";
			m_Desc = "All you need is a very unstable rocket.\n That explodes.";
			m_Time = 1.0f;
			m_PerkType = k_eBad;
			m_NoRollEndNotify = true;
			g_rtd.RegisterItem( this );
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			pPlayer.Teleport( pPlayer.GetAbsOrigin(), pPlayer.GetAbsAngles(), Vector( 0, 0, 1500.0 ) );
			Rocket::AttachParticle( pPlayer, "rockettrail", m_Time );
			Schedule::Task( m_Time, pPlayer.entindex(), RTD::Rocket::Explode );
		}
	}
}