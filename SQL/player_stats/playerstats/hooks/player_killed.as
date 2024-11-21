HookReturnCode OnPlayerKilled( CTerrorPlayer@ pPlayer, CTakeDamageInfo &in DamageInfo )
{
    CBaseEntity @pAttacker = DamageInfo.GetAttacker();
    if ( pAttacker is null ) return HOOK_CONTINUE;
    g_HasAPlayerDied = true;
    if ( ThePresident.GetGameModeType() == GM_HUNTED )
    {
        if ( pPlayer.GetTeamNumber() == TEAM_SURVIVOR )
            OnPlayerKilledState( pAttacker, k_SurvivorKilledHunted );
        else
            OnPlayerKilledState( pAttacker, k_InfectedKilledHunted );
    }
    else
    {
        if ( pPlayer.GetTeamNumber() == pAttacker.GetTeamNumber() )
        {
            if ( pPlayer.entindex() != pAttacker.entindex() )
                OnPlayerKilledState( pAttacker, k_AwardTeamKill );
        }
        else
        {
            if ( pPlayer.GetTeamNumber() == TEAM_SURVIVOR )
            {
                OnPlayerKilledState( pAttacker, k_SurvivorKilled );
                PlayerLeftForDead();
            }
            else if ( pPlayer.GetTeamNumber() == TEAM_ZOMBIE )
                OnPlayerKilledState( pAttacker, k_InfectedKilled );
        }
    }
    return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

void OnPlayerKilledState( CBaseEntity@ pAttacker, PlayerUpdateState state )
{
    CTerrorPlayer@ pTerror = ToTerrorPlayer( pAttacker );
    if ( pTerror is null ) return;
    OnPlayerStatsUpdated( pTerror, state );
}

//------------------------------------------------------------------------------------------------------------------------//

void PlayerLeftForDead()
{
    array<int> collector = Utils.CollectPlayers();
    if ( collector.length() > 0 )
    {
        // Go trough our collector
        CTerrorPlayer@ pTerror = null;
        for ( uint i = 0; i < collector.length(); i++ )
        {
            @pTerror = ToTerrorPlayer( collector[ i ] );
            if ( pTerror.GetTeamNumber() != TEAM_SURVIVOR ) continue;
            if ( !pTerror.IsAlive() ) continue;
            OnPlayerStatsUpdated( pTerror, k_AwardLeft4Dead );
        }
    }
}