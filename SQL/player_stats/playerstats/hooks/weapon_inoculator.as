HookReturnCode InoculatorHeal( CTerrorPlayer@ pOwner, CBaseEntity@ pTarget )
{
    OnPlayerStatsUpdated( pOwner, k_AwardInoculator );
    return HOOK_CONTINUE;
}