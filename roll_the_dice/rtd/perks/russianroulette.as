namespace RTD
{
	class CPerkRussianRoulette : IRollTheDiceTypeBase
	{
		private array<int> m_Cache;

		CPerkRussianRoulette()
		{
			m_ID = "russianroulette";
			m_Name = "Russian Roulette";
			m_Desc = "The next bullet fired may kill the player.\n Maybe.";
			m_Time = 15.0f;
			m_PerkType = k_eBad;
			for ( int x = 0; x <= Globals.GetMaxClients(); x++ )
				m_Cache.insertLast( 0 );
			g_rtd.RegisterItem( this );
		}

		void ClearData()
		{
			for ( uint x = 0; x < m_Cache.length(); x++ )
				m_Cache[x] = 0;
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			m_Cache[pPlayer.entindex()] = Math::RandomInt( 1, 6 );
		}

		bool CanHarmEnemy( int client)
		{
			bool ret = m_Cache[client] == 1 ? false : true;
			m_Cache[client] = Math::RandomInt( 1, 6 );
			return ret;
		}

		HookReturnCode OnInfectedDamagedPre(Infected@ pInfected, CTakeDamageInfo &in DamageInfo)
		{
			CBaseEntity @pAttacker = DamageInfo.GetAttacker();
			if ( pAttacker is null ) return HOOK_CONTINUE;
			if ( !CanHarmEnemy(pAttacker.entindex()) )
				pAttacker.TakeDamage( CTakeDamageInfo( pAttacker, pAttacker.GetHealth(), DMG_SLASH ) );
			return HOOK_CONTINUE;
		}

		HookReturnCode OnPlayerDamagedPre(CTerrorPlayer@ pPlayer, CTakeDamageInfo &in DamageInfo)
		{
			CBaseEntity @pAttacker = DamageInfo.GetAttacker();
			if ( pAttacker is null ) return HOOK_CONTINUE;
			if ( !CanHarmEnemy(pAttacker.entindex()) )
				pAttacker.TakeDamage( CTakeDamageInfo( pAttacker, pAttacker.GetHealth(), DMG_SLASH ) );
			return HOOK_CONTINUE;
		}
	}
}