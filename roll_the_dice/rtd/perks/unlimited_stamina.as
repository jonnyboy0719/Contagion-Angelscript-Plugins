namespace RTD
{
	namespace Stamina
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
			NetProp::SetPropFloat( client, "m_flStamina", NetProp::GetPropFloat( client, "m_flMaxStamina" ) );
			Schedule::Task( 0.1, client, RTD::Stamina::Think );
		}
	}
	class CPerkUnlimitedStamina : IRollTheDiceTypeBase
	{
		CPerkUnlimitedStamina()
		{
			m_ID = "unlimited_stamina";
			m_Name = "Unlimited Stamina";
			m_Desc = "Grants you unlimited stamina for 10 seconds.";
			m_Time = 10.0f;
			m_PerkType = k_eGood;
			g_rtd.RegisterItem( this );
		}

		void OnRollEnd( CTerrorPlayer @pPlayer, PerkState ePerk )
		{
			if ( pPlayer is null ) return;
			Stamina::RemoveFromList( pPlayer.entindex() );
		}

		void ClearData()
		{
			Stamina::m_iPlayers.removeRange(0, Stamina::m_iPlayers.length() - 1);
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			if ( Stamina::IsValidIndex( pPlayer.entindex() ) ) return;
			Stamina::m_iPlayers.insertLast( pPlayer.entindex() );
			Schedule::Task( 0.1, pPlayer.entindex(), RTD::Stamina::Think );
		}
	}
}