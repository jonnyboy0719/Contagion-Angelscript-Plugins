namespace RTD
{
	namespace UnlimitedAmmo
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
			CBaseEntity @pCurrentWeapon = pTarget.GetCurrentWeapon();
			if ( pCurrentWeapon !is null )
			{
				CTerrorWeapon @pTerrorWeapon = ToTerrorWeapon( pCurrentWeapon );
				if ( pTerrorWeapon !is null )
				{
					int maxammo = pTerrorWeapon.GetMaxClip();
					pTerrorWeapon.m_iClip = maxammo;
				}
			}
			Schedule::Task( 0.01, client, RTD::UnlimitedAmmo::Think );
		}
	}
	class CPerkUnlimitedAmmo : IRollTheDiceTypeBase
	{
		CPerkUnlimitedAmmo()
		{
			m_ID = "unlimited_ammo";
			m_Name = "Unlimited God";
			m_Desc = "Grants you unlimited ammo for 10 seconds.";
			m_Time = 10.0f;
			m_PerkType = k_eGood;
			g_rtd.RegisterItem( this );
		}

		void OnRollEnd( CTerrorPlayer @pPlayer, PerkState ePerk )
		{
			if ( pPlayer is null ) return;
			UnlimitedAmmo::RemoveFromList( pPlayer.entindex() );
		}

		void ClearData()
		{
			UnlimitedAmmo::m_iPlayers.removeRange(0, UnlimitedAmmo::m_iPlayers.length() - 1);
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			if ( UnlimitedAmmo::IsValidIndex( pPlayer.entindex() ) ) return;
			UnlimitedAmmo::m_iPlayers.insertLast( pPlayer.entindex() );
			Schedule::Task( 0.01, pPlayer.entindex(), RTD::UnlimitedAmmo::Think );
		}
	}
}