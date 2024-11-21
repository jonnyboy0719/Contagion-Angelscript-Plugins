void Event_GameEnd( ASGameEvent &in event )
{
    if ( !event.GetBool( "campaign" ) ) return;
    array<int> collector = Utils.CollectPlayers();
    if ( collector.length() > 0 )
    {
        // Go trough our collector
        CTerrorPlayer@ pTerror = null;
        for ( uint i = 0; i < collector.length(); i++ )
        {
            @pTerror = ToTerrorPlayer( collector[ i ] );
            OnPlayerStatsUpdated( pTerror, k_AwardCampaign );
        }
    }
}