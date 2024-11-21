HookReturnCode OnPlayerConnected( CTerrorPlayer@ pPlayer )
{
    if ( gMainConnection is null ) return HOOK_CONTINUE;
    if ( pPlayer.IsBot() ) return HOOK_CONTINUE;
    SQL::TryReconnect( gMainConnection );
    CheckPlayerConnected( pPlayer );
    CalculateRanks();
    SQL::SendQuery(
        gMainConnection,
        "SELECT * FROM stats_players WHERE steam_id = '" + pPlayer.GetSteamID64() + "'",
        Query_PlayerConnected
    );
    return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

void CheckPlayerConnected( CTerrorPlayer @pPlayer )
{
    if ( pPlayer is null ) return;
    if ( pPlayer.IsBot() ) return;
    SQL::SendQuery(
        gMainConnection,
        "INSERT INTO stats_players (steam_id, last_known_alias, last_join_date)\n"
        "VALUES ('" + pPlayer.GetSteamID64() + "', '" + Utils.EscapeCharacters( pPlayer.GetPlayerName() ) + "', CURRENT_TIMESTAMP())\n"
        "ON DUPLICATE KEY UPDATE last_join_date = CURRENT_TIMESTAMP(), last_known_alias = '" + Utils.EscapeCharacters( pPlayer.GetPlayerName() ) + "'"
    );
}

//------------------------------------------------------------------------------------------------------------------------//

void CalculateRanks()
{
    SQL::SendQuery(
        gMainConnection,
        "SELECT `last_known_alias`, `steam_id`, `award_escape`, `points`, `survivor_killed`, `survivor_infected`, `survivor_grappled`, `infected_killed`, `infected_headshot`, `infected_crippled`, `kills_melee`, `kills_doctors`, `kills_looters`, `kills_riots`, `kills_chargers` FROM stats_players ORDER BY points ASC",
        Query_PlayerRanks
    );
}

//------------------------------------------------------------------------------------------------------------------------//

void Query_PlayerRanks( IMySQL@ pQuery )
{
    if ( pQuery is null ) return;
    if ( pQuery.Failed() ) return;
    
    // Clear it
    player_ranks.removeRange(0, player_ranks.length());
    // We start from 1, not 0 for the rank number
    int iRank     = 1;
    bool find_res = true;
    //CTerrorPlayer @pPlayer = null;
    while( find_res )
    {
        PlayerRank @pHandle = PlayerRank( iRank );
        pHandle.AddFromQuery( pQuery );
        player_ranks.insertLast( pHandle );
        iRank++;
        find_res = SQL::NextResult( pQuery );
    }
}

//------------------------------------------------------------------------------------------------------------------------//

void Query_PlayerConnected( IMySQL@ pQuery )
{
    if ( pQuery is null ) return;
    if ( pQuery.Failed() ) return;
    if ( !g_pAnnounceOnConnect.GetBool() ) return;
    
    string strAuthID = SQL::ReadResult::GetString( pQuery, "steam_id" );
    CTerrorPlayer @pPlayer = GetPlayerBySteamID( strAuthID );

    if ( pPlayer is null ) return;
    
    int rank_pos    = player_ranks.length();
    int rank_points = 0;
    
    PlayerRank @handle = GrabPlayerRank( strAuthID );
    if ( handle !is null )
    {
        rank_pos        = handle.rank;
        rank_points     = handle.points;
        handle.playtime = Globals.GetCurrentTime();
    }
    OnPlayerConnection( pPlayer, true, rank_pos, rank_points );
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerDisconnected( CTerrorPlayer@ pPlayer )
{
    if ( pPlayer.IsBot() ) return HOOK_CONTINUE;
    OnPlayerConnection( pPlayer, false, 0, 0.0f );
    return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

void OnPlayerConnection( CTerrorPlayer@ pPlayer, const bool &in bConnected, int rank_pos, int rank_points )
{
    // Grab the IP (but get rid of the port)
    string ipLoc = pPlayer.GrabIP();
    CASCommand @args = StringToArgSplit( ipLoc, ":" );
    string conLocation = GeoIP::GrabLocation( args.Arg( 0 ) );

    // Did we connect or disconnect?
    string conString = bConnected ? "{green}joined the game" : "{red}left the game";
    if ( !pPlayer.IsBot() && bConnected )
        conString += " {default}from {community}" + conLocation + " {default}({greenyellow}Rank:{default} " + rank_pos + ", {greenyellow}Points:{default} " + rank_points + ")";

    // Grab our SteamID
    string steamid = Utils.Convert( STEAMID32, pPlayer.GetSteamID64() );

    // If this is a bot, then change the steamid with the ipLoc (it will say BOT)
    if ( pPlayer.IsBot() ) steamid = ipLoc;

    // Print to chat
    Chat.PrintToChat( all, "{default}Player '{greenyellow}" + pPlayer.GetPlayerName() + "{default}' {gold}({greenyellow}" + steamid + "{gold}) {default}has " + conString );
}
