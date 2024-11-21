void Event_RoundEnd( ASGameEvent &in event )
{
    if ( event.GetInt( "winner" ) != TEAM_ZOMBIE ) return;
    array<int> collector = Utils.CollectPlayers();
    if ( collector.length() > 0 )
    {
        // Go trough our collector
        CTerrorPlayer@ pTerror = null;
        for ( uint i = 0; i < collector.length(); i++ )
        {
            @pTerror = ToTerrorPlayer( collector[ i ] );
            if ( pTerror.GetTeamNumber() == TEAM_ZOMBIE )
                OnPlayerStatsUpdated( pTerror, k_AwardInfectedWin );
        }
    }
}