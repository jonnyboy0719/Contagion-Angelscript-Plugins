namespace RTD
{
	class CPerkUnluckySpawn : IRollTheDiceTypeBase
	{
		CPerkUnluckySpawn()
		{
			m_ID = "unluckyspawn";
			m_Name = "Unlucky Spawn";
			m_Desc = "A random zombie will spawn around you.";
			m_Time = 5.0f;
			m_PerkType = k_eBad;
			m_NoRollEndNotify = true;
			g_rtd.RegisterItem( this );
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			Vector vec_start = pPlayer.GetAbsOrigin() + Vector( Math::RandomFloat( -155, 155 ), Math::RandomFloat( -155, 155 ), 150 );
			string szTemp;
			switch( Math::RandomInt( 0, 4 ) )
			{
				case 0: szTemp = "zombiecarrier"; break;
				case 1: szTemp = "zombiecharger"; break;
				case 2: szTemp = "zombielooter"; break;
				case 3: szTemp = "zombieriot"; break;
				case 4: szTemp = "zombiedoctor"; break;
			}
			EntityCreator::Create( szTemp, vec_start, pPlayer.EyeAngles() );
		}
	}
}