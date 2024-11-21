namespace RTD
{
	namespace Voices
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

		void Think( int client )
		{
			if ( !IsValidIndex( client ) ) return;
			CTerrorPlayer @pTarget = ToTerrorPlayer( client );
			string szTemp;
			switch( Math::RandomInt( 0, 4 ) )
			{
				case 0: szTemp = "VO_Zombie_Roar"; break;
				case 1: szTemp = "VO_Zombie_Pain"; break;
				case 2: szTemp = "VO_Zombie_Idle"; break;
				case 3: szTemp = "VO_Zombie_Grapple"; break;
				case 4: szTemp = "VO_Zombie_Attack"; break;
			}
			pTarget.PlayWwiseSound( "VO_Zombie_Stop", "", -1 );
			pTarget.PlayWwiseSound( szTemp, "", -1 );
			Schedule::Task( Math::RandomFloat( 0.3f, 1.8f ), client, RTD::Turtles::Think );
		}
	}

	class CPerkVoices : IRollTheDiceTypeBase
	{
		CPerkVoices()
		{
			m_ID = "voices";
			m_Name = "Voices?";
			m_Desc = "There are voices inside your head.";
			m_Time = 15.0f;
			m_PerkType = k_eNeutral;
			g_rtd.RegisterItem( this );
		}

		void OnRollEnd( CTerrorPlayer @pPlayer, PerkState ePerk )
		{
			if ( pPlayer is null ) return;
			Voices::RemoveFromList( pPlayer.entindex() );
			pPlayer.PlayWwiseSound( "VO_Zombie_Stop", "", -1 );
		}

		void ClearData()
		{
			Voices::m_iPlayers.removeRange(0, Voices::m_iPlayers.length() - 1);
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			if ( Voices::IsValidIndex( pPlayer.entindex() ) ) return;
			Voices::m_iPlayers.insertLast( pPlayer.entindex() );
			Schedule::Task( 0.01, pPlayer.entindex(), RTD::Voices::Think );
		}
	}
}