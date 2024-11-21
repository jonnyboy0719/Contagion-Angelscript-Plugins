void Event_PlayerProtected( ASGameEvent &in event )
{
    CTerrorPlayer @pPlayer = FromUserID( event.GetInt( "helper_userid" ) );
    if ( pPlayer is null ) return;
    OnPlayerStatsUpdated( pPlayer, k_AwardProtect );
}