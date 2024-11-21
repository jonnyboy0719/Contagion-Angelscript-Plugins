namespace RTD
{
	class CPerkEmptyMagazine : IRollTheDiceTypeBase
	{
		CPerkEmptyMagazine()
		{
			m_ID = "emptymagazine";
			m_Name = "Empty Magazine";
			m_Desc = "Your current equipped weapon's magazine will drop to 0.";
			m_Time = 1.0f;
			m_PerkType = k_eBad;
			m_NoRollEndNotify = true;
			g_rtd.RegisterItem( this );
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			CBaseEntity @pCurrentWeapon = pPlayer.GetCurrentWeapon();
			if ( pCurrentWeapon !is null )
			{
				CTerrorWeapon @pTerrorWeapon = ToTerrorWeapon( pCurrentWeapon );
				if ( pTerrorWeapon !is null )
					pTerrorWeapon.m_iClip = 0;
			}
		}
	}
}