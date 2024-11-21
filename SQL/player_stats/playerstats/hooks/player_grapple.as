HookReturnCode OnPlayerGrapple( CTerrorPlayer@ pVictim, CBaseEntity@ pAttacker )
{
    CTerrorPlayer@ pTerror = ToTerrorPlayer( pAttacker );
    if ( pTerror is null ) return HOOK_CONTINUE;
    OnPlayerStatsUpdated( pTerror, k_SurvivorGrappled );
    return HOOK_CONTINUE;
}
