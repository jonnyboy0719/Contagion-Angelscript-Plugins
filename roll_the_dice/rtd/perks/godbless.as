namespace RTD
{
	class CPerkGodBless : IRollTheDiceTypeBase
	{
		CPerkGodBless()
		{
			m_ID = "godbless";
			m_Name = "God Bless You";
			m_Desc = "Randomly gives you 15hp to 55hp.\nIt will however not go over the maximum HP amount.";
			m_Time = 3.0f;
			m_NoRollEndNotify = true;
			m_PerkType = k_eGood;
			g_rtd.RegisterItem( this );
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			int hp = pPlayer.GetHealth();
			int maxhp = pPlayer.GetMaxHealth();
			hp += Math::RandomInt( 15, 55 );
			if ( hp > maxhp ) hp = maxhp;
			pPlayer.SetHealth(hp);
		}
	}
}