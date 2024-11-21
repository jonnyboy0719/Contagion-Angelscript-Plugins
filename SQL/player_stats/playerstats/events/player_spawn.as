void Event_PlayerSpawned( ASGameEvent &in event )
{
    CTerrorPlayer @pPlayer = FromUserID( event.GetInt( "userid" ) );
    if ( pPlayer is null ) return;
    if ( g_pShowRankOnConnect.GetBool() )
        Menu::Draw( pPlayer, Menu::k_MenuDraw_Rank );
}