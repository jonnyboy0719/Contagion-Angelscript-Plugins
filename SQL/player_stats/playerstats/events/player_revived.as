void Event_PlayerRevived( ASGameEvent &in event )
{
    CTerrorPlayer @pPlayer = FromUserID( event.GetInt( "alive_userid" ) );
    if ( pPlayer is null ) return;
    OnPlayerStatsUpdated( pPlayer, k_AwardDefib );
}