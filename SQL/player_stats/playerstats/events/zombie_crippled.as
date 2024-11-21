void Event_ZombieCrippled( ASGameEvent &in event )
{
    CTerrorPlayer @pPlayer = FromUserID( event.GetInt( "userid" ) );
    if ( pPlayer is null ) return;
    OnPlayerStatsUpdated( pPlayer, k_InfectedCrippled );
}