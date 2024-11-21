void Event_PlayerGrappled( ASGameEvent &in event )
{
    CTerrorPlayer @pPlayer = ToTerrorPlayer( event.GetInt( "attacker" ) );
    if ( pPlayer is null ) return;
    OnPlayerStatsUpdated( pPlayer, k_SurvivorGrappled );
}