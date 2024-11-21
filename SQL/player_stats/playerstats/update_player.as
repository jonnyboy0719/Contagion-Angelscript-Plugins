enum PlayerUpdateState
{
    k_None = 0,
    k_SurvivorKilled,
    k_SurvivorKilledHunted,
    k_SurvivorInfected,
    k_SurvivorGrappled,
    k_InfectedKilled,
    k_InfectedKilledHunted,
    k_InfectedHeadShot,
    k_InfectedCrippled,
    k_KillsMelee,
    k_KillsDoctors,
    k_KillsLooters,
    k_KillsRiots,
    k_KillsChargers,
    k_AwardCampaign,
    k_AwardEscape,
    k_AwardAllInSafeHouse,
    k_AwardMedKit,
    k_AwardInoculator,
    k_AwardDefib,
    k_AwardProtect,
    k_AwardInfectedWin,
    k_AwardFriendlyFire,
    k_AwardTeamKill,
    k_AwardLeft4Dead
}

//------------------------------------------------------------------------------------------------------------------------//

void OnPlayerStatsUpdated( CTerrorPlayer@ pPlayer, PlayerUpdateState state )
{
    if ( pPlayer is null ) return;
    if ( pPlayer.IsBot() ) return;
    if ( gMainConnection is null ) return;
    string strQry   = "";
    int pointsgiven = 0;
    bool good_award = true;
    
    switch( state )
    {
        case k_SurvivorKilled: strQry = "survivor_killed"; pointsgiven = 5; break;
        case k_SurvivorKilledHunted: strQry = "survivor_killed_hunted"; pointsgiven = 5; break;
        case k_SurvivorInfected: strQry = "survivor_infected"; pointsgiven = 8; break;
        case k_SurvivorGrappled: strQry = "survivor_grappled"; pointsgiven = 2; break;
        case k_InfectedKilled: strQry = "infected_killed"; pointsgiven = 3; break;
        case k_InfectedKilledHunted: strQry = "infected_killed_hunted"; pointsgiven = 3; break;
        case k_InfectedHeadShot: strQry = "infected_headshot"; pointsgiven = 4; break;
        case k_InfectedCrippled: strQry = "infected_crippled"; pointsgiven = 1; break;
        case k_KillsMelee: strQry = "kills_melee"; pointsgiven = 5; break;
        case k_KillsDoctors: strQry = "kills_doctors"; pointsgiven = 2; break;
        case k_KillsLooters: strQry = "kills_looters"; pointsgiven = 3; break;
        case k_KillsRiots: strQry = "kills_riots"; pointsgiven = 8; break;
        case k_KillsChargers: strQry = "kills_chargers"; pointsgiven = 10; break;
        case k_AwardCampaign: strQry = "award_campaigns"; pointsgiven = 100; break;
        case k_AwardEscape: strQry = "award_escape"; pointsgiven = 25; break;
        case k_AwardAllInSafeHouse: strQry = "award_allinsafehouse"; pointsgiven = 50; break;
        case k_AwardMedKit: strQry = "award_medkit"; pointsgiven = 30; break;
        case k_AwardInoculator: strQry = "award_inoculator"; pointsgiven = 15; break;
        case k_AwardDefib: strQry = "award_defib"; pointsgiven = 250; break;
        case k_AwardProtect: strQry = "award_protect"; pointsgiven = 150; break;
        case k_AwardInfectedWin: strQry = "award_infected_win"; pointsgiven = 50; break;
        case k_AwardFriendlyFire: strQry = "award_friendlyfire"; pointsgiven = 4; good_award = false; break;
        case k_AwardTeamKill: strQry = "award_teamkill"; pointsgiven = 100; good_award = false; break;
        case k_AwardLeft4Dead: strQry = "award_left4dead"; pointsgiven = 80; good_award = false; break;
    }
    
    if ( strQry == "" ) return;
    SQL::TryReconnect( gMainConnection );
    
    string extra_qry = "";
    if ( good_award )
        extra_qry = OnPlayerPointsIncrement( pPlayer, pointsgiven );
    else
        extra_qry = OnPlayerPointsDecrement( pPlayer, pointsgiven );
    
    dictionary @dict = {
        {"steamid", pPlayer.GetSteamID64()},
        {"query", strQry},
        {"extra", extra_qry}
    };
    SQL::SendAndIgnoreQueryEx(
        gMainConnection,
        "UPDATE stats_players SET " + strQry + " = " + strQry + " + 1" + extra_qry + " WHERE steam_id = '" + pPlayer.GetSteamID64() + "';",
        Query_OnPlayerUpdateInfoFailCheck,
        dict
    );
    PlayerRank @handle = GrabPlayerRank( pPlayer.GetSteamID64() );
    if ( handle !is null )
        handle.UpdateLocalData( strQry, 1, true );
    CheckMapVictoryState( state );
}

//------------------------------------------------------------------------------------------------------------------------//

void Query_OnPlayerUpdateInfoFailCheck( IMySQL@ pQuery )
{
    if ( pQuery is null ) return;
    // we only want to resend our data, IF we fail, however, we only do this once.
    if ( !pQuery.Failed() ) return;
    if ( gMainConnection is null ) return;
    SQL::TryReconnect( gMainConnection );
    string strSteamID = string( dict['steamid'] );
    string strQry     = string( dict['query'] );
    string strExtra   = string( dict['extra'] );
    SQL::SendAndIgnoreQuery(
        gMainConnection,
        "UPDATE stats_players SET " + strQry + " = " + strQry + " + 1" + strExtra + " WHERE steam_id = '" + strSteamID + "';"
    );
}

//------------------------------------------------------------------------------------------------------------------------//

string OnPlayerPointsIncrement( CTerrorPlayer@ pPlayer, int points )
{
    if ( pPlayer is null ) return "";
    if ( pPlayer.IsBot() ) return "";
    if ( points > 0 )
    {
        PlayerRank @handle = GrabPlayerRank( pPlayer.GetSteamID64() );
        if ( handle !is null )
            handle.UpdateLocalData( "points", points, true );
        return ",points = points + " + points;
    }
    return "";
}

//------------------------------------------------------------------------------------------------------------------------//

void CheckMapVictoryState( CTerrorPlayer@ pPlayer, PlayerUpdateState state )
{
    PlayerRank @handle = GrabPlayerRank( pPlayer.GetSteamID64() );
    if ( handle is null ) return;
    double MapPlayTime = double(Globals.GetCurrentTime() - handle.playtime);
    dictionary @dict = {
        {"steamid", pPlayer.GetSteamID64()},
        {"playtime", MapPlayTime}
    };
    SQL::SendAndIgnoreQueryEx(
        gMainConnection,
        "INSERT INTO stats_maps_timed (steamid, plays, time, map, difficulty)\n"
        "VALUES ('" + pPlayer.GetSteamID64() + "', '1', '" + MapPlayTime + "', '" + Globals.GetCurrentMapName() + "', '" + Utils.GetDifficulty() + "')\n"
        "ON DUPLICATE KEY UPDATE modified = CURRENT_TIMESTAMP(), time = '" + MapPlayTime + "', plays = plays + 1",
        Query_OnCheckMapVictoryStateFailCheck,
        dict
    );
}

//------------------------------------------------------------------------------------------------------------------------//

void Query_OnCheckMapVictoryStateFailCheck( IMySQL@ pQuery )
{
    if ( pQuery is null ) return;
    // we only want to resend our data, IF we fail, however, we only do this once.
    if ( !pQuery.Failed() ) return;
    if ( gMainConnection is null ) return;
    SQL::TryReconnect( gMainConnection );
    string strSteamID = string( dict['steamid'] );
    double dbPlayTime = double( dict['playtime'] );
    SQL::SendAndIgnoreQuery(
        gMainConnection,
        "INSERT INTO stats_maps_timed (steamid, plays, time, map, difficulty)\n"
        "VALUES ('" + strSteamID + "', '1', '" + dbPlayTime + "', '" + Globals.GetCurrentMapName() + "', '" + Utils.GetDifficulty() + "')\n"
        "ON DUPLICATE KEY UPDATE modified = CURRENT_TIMESTAMP(), time = '" + dbPlayTime + "', plays = plays + 1"
    );
}

//------------------------------------------------------------------------------------------------------------------------//

string OnPlayerPointsDecrement( CTerrorPlayer@ pPlayer, int points )
{
    if ( pPlayer is null ) return "";
    if ( pPlayer.IsBot() ) return "";
    if ( points > 0 )
    {
        PlayerRank @handle = GrabPlayerRank( pPlayer.GetSteamID64() );
        if ( handle !is null )
            handle.UpdateLocalData( "points", points, false );
        return ",points = points - " + points;
    }
    return "";
}
