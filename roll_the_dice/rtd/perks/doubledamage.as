namespace RTD
{
	class CPerkDoubleDamage : IRollTheDiceTypeBase
	{
		CPerkDoubleDamage()
		{
			m_ID = "doubledamage";
			m_Name = "Double Damage";
			m_Desc = "Your weapon deals double the damage for 20 seconds.";
			m_Time = 20.0f;
			m_PerkType = k_eGood;
			g_rtd.RegisterItem( this );
		}

		void PlayHit(int client)
		{
			array<int> collector = Utils.CollectPlayers();
			if ( collector.length() > 0 )
			{
				// Go trough our collector
				CTerrorPlayer@ pTerror = null;
				for ( uint i = 0; i < collector.length(); i++ )
				{
					@pTerror = ToTerrorPlayer( collector[ i ] );
					pTerror.PlayWwiseSound( "Q2_DoubleDamage_Hit", client, -1 );
				}
			}
		}

		HookReturnCode OnInfectedDamagedPre(Infected@ pInfected, CTakeDamageInfo &in DamageInfo)
		{
			CBaseEntity @pAttacker = DamageInfo.GetAttacker();
			if ( pAttacker !is null )
			{
				DamageInfo.SetDamage( DamageInfo.GetDamage() * 4.0f );
				PlayHit( pAttacker.entindex() );
			}
			return HOOK_CONTINUE;
		}

		HookReturnCode OnPlayerDamagedPre(CTerrorPlayer@ pPlayer, CTakeDamageInfo &in DamageInfo)
		{
			CBaseEntity @pAttacker = DamageInfo.GetAttacker();
			if ( pAttacker !is null )
			{
				DamageInfo.SetDamage( DamageInfo.GetDamage() * 4.0f );
				PlayHit( pAttacker.entindex() );
			}
			return HOOK_HANDLED;
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			pPlayer.PlayWwiseSound( "Q2_DoubleDamage_Get", "", -1 );
		}
	}
}