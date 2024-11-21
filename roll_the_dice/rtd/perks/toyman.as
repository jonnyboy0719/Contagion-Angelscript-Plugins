namespace RTD
{
	class CPerkToyMan : IRollTheDiceTypeBase
	{
		private array<float> m_Cache;

		CPerkToyMan()
		{
			m_ID = "toy";
			m_Name = "Little Toy's";
			m_Desc = "For a limited time, your size will be decreased by 80%.";
			m_Time = 8.0f;
			m_PerkType = k_eNeutral;
			for ( int x = 0; x <= Globals.GetMaxClients(); x++ )
				m_Cache.insertLast( 0.0f );
			g_rtd.RegisterItem( this );
		}

		void ClearData()
		{
			for ( uint x = 0; x < m_Cache.length(); x++ )
				m_Cache[x] = 0.0f;
		}

		void OnRollEnd( CTerrorPlayer @pPlayer, PerkState ePerk )
		{
			if ( pPlayer is null ) return;
			NetProp::SetPropFloat( pPlayer.entindex(), "m_flModelScale", m_Cache[pPlayer.entindex()] );
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			m_Cache[pPlayer.entindex()] = NetProp::GetPropFloat( pPlayer.entindex(), "m_flModelScale" );
			NetProp::SetPropFloat( pPlayer.entindex(), "m_flModelScale", 0.2f );
		}
	}
}