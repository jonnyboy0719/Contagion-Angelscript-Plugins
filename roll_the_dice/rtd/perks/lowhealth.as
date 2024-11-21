namespace RTD
{
	class CPerkLowHP : IRollTheDiceTypeBase
	{
		CPerkLowHP()
		{
			m_ID = "lowhp";
			m_Name = "Low Health";
			m_Desc = "Your health will be forcefully be set to 25%.";
			m_Time = 3.0f;
			m_PerkType = k_eBad;
			m_NoRollEndNotify = true;
			g_rtd.RegisterItem( this );
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			pPlayer.SetHealth( 25 );
			pPlayer.Vocalize( k_eVoicePain );
		}
	}
}