namespace RTD
{
	class CPerkHeadshotExpert : IRollTheDiceTypeBase
	{
		CPerkHeadshotExpert()
		{
			m_ID = "headshotonly";
			m_Name = "Headshot Expert";
			m_Desc = "You are only allowed to shoot at the head.";
			m_Time = 13.0f;
			m_PerkType = k_eBad;
			g_rtd.RegisterItem( this );
		}

		HookReturnCode OnInfectedDamagedPre(Infected@ pInfected, CTakeDamageInfo &in DamageInfo)
		{
			CBaseEntity @pAttacker = DamageInfo.GetAttacker();
			if ( pAttacker !is null && pInfected.LastHitGroup() == HITGROUP_HEAD )
				return HOOK_CONTINUE;
			return HOOK_HANDLED;
		}

		HookReturnCode OnPlayerDamagedPre(CTerrorPlayer@ pPlayer, CTakeDamageInfo &in DamageInfo)
		{
			CBaseEntity @pAttacker = DamageInfo.GetAttacker();
			if ( pAttacker !is null && pPlayer.LastHitGroup() == HITGROUP_HEAD )
				return HOOK_CONTINUE;
			return HOOK_HANDLED;
		}
	}
}