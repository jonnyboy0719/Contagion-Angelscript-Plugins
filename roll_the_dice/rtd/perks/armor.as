namespace RTD
{
	class CPerkArmor : IRollTheDiceTypeBase
	{
		CPerkArmor()
		{
			m_ID = "armor";
			m_Name = "Armored Tank";
			m_Desc = "Increases your health by 200hp.\nMaximum being 250hp.";
			m_Time = 3.0f;
			m_PerkType = k_eGood;
			m_NoRollEndNotify = true;
			g_rtd.RegisterItem( this );
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			int hp = pPlayer.GetHealth();
			int maxhp = 250;
			hp += 200;
			if ( hp > maxhp ) hp = maxhp;
			pPlayer.SetHealth(hp);
		}
	}
}