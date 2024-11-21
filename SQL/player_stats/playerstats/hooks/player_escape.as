HookReturnCode OnPlayerEscape( CTerrorPlayer@ pPlayer )
{
    OnPlayerStatsUpdated( pPlayer, k_AwardEscape );
    return HOOK_CONTINUE;
}
