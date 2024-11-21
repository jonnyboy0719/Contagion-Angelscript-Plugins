HookReturnCode OnPlayerInfectedEx( CTerrorPlayer@ pPlayer, CTerrorPlayer@ pTerror, InfectionState iState )
{
    if ( iState == state_infection )
        OnPlayerStatsUpdated( pTerror, k_SurvivorInfected );
    return HOOK_CONTINUE;
}