HookReturnCode FirstAidHeal( CTerrorPlayer@ pOwner, CBaseEntity@ pTarget )
{
    OnPlayerStatsUpdated( pOwner, k_AwardMedKit );
    return HOOK_CONTINUE;
}