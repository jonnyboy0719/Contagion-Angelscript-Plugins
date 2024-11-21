namespace RTD
{
	class CPerkReverseGravity : IRollTheDiceTypeBase
	{
		private array<float> m_GravityCache;

		CPerkReverseGravity()
		{
			m_ID = "gravity_reverse";
			m_Name = "Reverse Gravity";
			m_Desc = "Your gravity will be reversed.";
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
			NetProp::SetPropFloat( pPlayer.entindex(), "m_flGravity", -1.0f );
			pPlayer.Teleport( pPlayer.GetAbsOrigin(), pPlayer.GetAbsAngles(), Vector( 0, 0, 15 ) );
		}
	}
}