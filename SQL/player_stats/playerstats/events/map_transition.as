void Event_MapTransition( ASGameEvent &in event )
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
            if ( !g_HasAPlayerDied )
                OnPlayerStatsUpdated( pTerror, k_AwardAllInSafeHouse );
        }
    }
}