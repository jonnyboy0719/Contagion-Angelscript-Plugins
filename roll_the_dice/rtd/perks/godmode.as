namespace RTD
{
	class CPerkGodMode : IRollTheDiceTypeBase
	{
		CPerkGodMode()
		{
			m_ID = "god";
			m_Name = "Temporary God Mode";
			m_Desc = "You are invulnerable to any kind of damage.";
			m_Time = 10.0f;
			m_PerkType = k_eGood;
			g_rtd.RegisterItem( this );
		}

		void OnRollEnd( CTerrorPlayer @pPlayer, PerkState ePerk )
		{
			if ( pPlayer is null ) return;
			pPlayer.SetGodMode( false );
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			pPlayer.SetGodMode( true );
		}
	}
}