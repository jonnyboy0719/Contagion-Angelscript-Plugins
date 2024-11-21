namespace RTD
{
	namespace Explode
	{
		array<int> m_iPlayers;
		bool IsValidIndex( int client )
		{
			for ( uint y = 0; y < m_iPlayers.length(); y++ )
			{
				int index = m_iPlayers[y];
				if ( index == client )
					return true;
			}
			return false;
		}

		void RemoveFromList( int client )
		{
			for ( uint y = 0; y < m_iPlayers.length(); y++ )
			{
				int index = m_iPlayers[y];
				if ( index == client )
				{
					m_iPlayers.removeAt(y);
					break;
				}
			}
		}

		void SpawnGrenade( CTerrorPlayer @pTerrorPlayer )
		{
			// Calculate position that the player is looking at.
			Vector vec_start = pTerrorPlayer.GetAbsOrigin() + Vector( Math::RandomFloat( -45, 45 ), Math::RandomFloat( -45, 45 ), 150 );
			QAngle qAng = QAngle( Math::RandomFloat( -45, 45 ), Math::RandomFloat( -45, 45 ), Math::RandomFloat( -45, 45 ) );
			Utils.SpawnGrenade( pTerrorPlayer, vec_start, Vector( 0, 0, 0 ), qAng, 1.2f );
		}

		void Think( int client )
		{
			if ( !IsValidIndex( client ) ) return;
			CTerrorPlayer @pTarget = ToTerrorPlayer( client );
			SpawnGrenade( pTarget );
			Schedule::Task( 0.3, client, RTD::Explode::Think );
		}
	}

	class CPerkExplode : IRollTheDiceTypeBase
	{
		CPerkExplode()
		{
			m_ID = "explode";
			m_Name = "Death By Explosion";
			m_Desc = "Grenades will spawn all around you,\n causing you and everyone around you to\n die a horrible, explosive death.";
			m_Time = 5.0f;
			m_PerkType = k_eBad;
			g_rtd.RegisterItem( this );
		}

		void OnRollEnd( CTerrorPlayer @pPlayer, PerkState ePerk )
		{
			if ( pPlayer is null ) return;
			Explode::RemoveFromList( pPlayer.entindex() );
		}

		void ClearData()
		{
			Explode::m_iPlayers.removeRange(0, Explode::m_iPlayers.length() - 1);
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			if ( Explode::IsValidIndex( pPlayer.entindex() ) ) return;
			Explode::m_iPlayers.insertLast( pPlayer.entindex() );
			Schedule::Task( 0.01, pPlayer.entindex(), RTD::Explode::Think );
		}
	}
}