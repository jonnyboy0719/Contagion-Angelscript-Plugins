namespace RTD
{
	class CPerkLowGravity : IRollTheDiceTypeBase
	{
		private array<float> m_GravityCache;

		CPerkLowGravity()
		{
			m_ID = "gravity_low";
			m_Name = "Low Gravity";
			m_Desc = "Your gravity will be reduced by 80%.";
			m_Time = 8.0f;
			m_PerkType = k_eBad;
			for ( int x = 0; x <= Globals.GetMaxClients(); x++ )
				m_GravityCache.insertLast( 0.0f );
			g_rtd.RegisterItem( this );
		}

		void ClearData()
		{
			for ( uint x = 0; x < m_GravityCache.length(); x++ )
				m_GravityCache[x] = 0.0f;
		}

		void OnRollEnd( CTerrorPlayer @pPlayer, PerkState ePerk )
		{
			if ( pPlayer is null ) return;
			NetProp::SetPropFloat( pPlayer.entindex(), "m_flGravity", m_GravityCache[pPlayer.entindex()] );
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			m_GravityCache[pPlayer.entindex()] = NetProp::GetPropFloat( pPlayer.entindex(), "m_flGravity" );
			NetProp::SetPropFloat( pPlayer.entindex(), "m_flGravity", 0.2f );
		}
	}
}