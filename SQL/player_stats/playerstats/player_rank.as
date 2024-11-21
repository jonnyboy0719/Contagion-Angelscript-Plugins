class PlayerRank
{
    int rank;
    int points;
    int escaped;
    int survivor_killed;
    int survivor_infected;
    int survivor_grappled;
    int infected_killed;
    int infected_headshot;
    int infected_crippled;
    int kills_melee;
    int kills_doctors;
    int kills_looters;
    int kills_riots;
    int kills_chargers;
    float playtime;         // Playtime on current map, will be set once the player joins.
    string name;
    string steamid;
    PlayerRank( int iRank ) { rank = iRank; playtime = 0; }
    
    void AddFromQuery( IMySQL@ pQuery )
    {
        survivor_killed   = SQL::ReadResult::GetInt( pQuery, "survivor_killed" );
        survivor_infected = SQL::ReadResult::GetInt( pQuery, "survivor_infected" );
        survivor_grappled = SQL::ReadResult::GetInt( pQuery, "survivor_grappled" );
        infected_killed   = SQL::ReadResult::GetInt( pQuery, "infected_killed" );
        infected_headshot = SQL::ReadResult::GetInt( pQuery, "infected_headshot" );
        infected_crippled = SQL::ReadResult::GetInt( pQuery, "infected_crippled" );
        kills_melee       = SQL::ReadResult::GetInt( pQuery, "kills_melee" );
        kills_doctors     = SQL::ReadResult::GetInt( pQuery, "kills_doctors" );
        kills_looters     = SQL::ReadResult::GetInt( pQuery, "kills_looters" );
        kills_riots       = SQL::ReadResult::GetInt( pQuery, "kills_riots" );
        kills_chargers    = SQL::ReadResult::GetInt( pQuery, "kills_chargers" );
        escaped           = SQL::ReadResult::GetInt( pQuery, "award_escape" );
        points            = SQL::ReadResult::GetInt( pQuery, "points" );
        steamid           = SQL::ReadResult::GetString( pQuery, "steam_id" );
        name              = SQL::ReadResult::GetString( pQuery, "last_known_alias" );
    }
    
    void UpdateLocalData( string key, int value, bool increment )
    {
        if ( Utils.StrEql( key, "survivor_killed" ) )
        {
            if ( increment ) survivor_killed += value;
            else survivor_killed -= value;
        }
        else if ( Utils.StrEql( key, "survivor_infected" ) )
        {
            if ( increment ) survivor_infected += value;
            else survivor_infected -= value;
        }
        else if ( Utils.StrEql( key, "survivor_grappled" ) )
        {
            if ( increment ) survivor_grappled += value;
            else survivor_grappled -= value;
        }
        else if ( Utils.StrEql( key, "infected_killed" ) )
        {
            if ( increment ) infected_killed += value;
            else infected_killed -= value;
        }
        else if ( Utils.StrEql( key, "infected_headshot" ) )
        {
            if ( increment ) infected_headshot += value;
            else infected_headshot -= value;
        }
        else if ( Utils.StrEql( key, "infected_crippled" ) )
        {
            if ( increment ) infected_crippled += value;
            else infected_crippled -= value;
        }
        else if ( Utils.StrEql( key, "kills_melee" ) )
        {
            if ( increment ) kills_melee += value;
            else kills_melee -= value;
        }
        else if ( Utils.StrEql( key, "kills_doctors" ) )
        {
            if ( increment ) kills_doctors += value;
            else kills_doctors -= value;
        }
        else if ( Utils.StrEql( key, "kills_looters" ) )
        {
            if ( increment ) kills_looters += value;
            else kills_looters -= value;
        }
        else if ( Utils.StrEql( key, "kills_riots" ) )
        {
            if ( increment ) kills_riots += value;
            else kills_riots -= value;
        }
        else if ( Utils.StrEql( key, "kills_chargers" ) )
        {
            if ( increment ) kills_chargers += value;
            else kills_chargers -= value;
        }
        else if ( Utils.StrEql( key, "escaped" ) )
        {
            if ( increment ) escaped += value;
            else escaped -= value;
        }
        else if ( Utils.StrEql( key, "points" ) )
        {
            if ( increment ) points += value;
            else points -= value;
        }
    }
}
array<PlayerRank@> player_ranks;

//------------------------------------------------------------------------------------------------------------------------//

PlayerRank @GrabPlayerRank( string strSteamID )
{
    for ( uint i = 0; i < player_ranks.length(); i++ )
    {
        PlayerRank @handle = player_ranks[i];
        if ( handle is null ) continue;
        if ( Utils.StrEql( strSteamID, handle.steamid ) ) return handle;
    }
    return null;
}

//------------------------------------------------------------------------------------------------------------------------//

PlayerRank @GrabPlayerFromID( uint id )
{
    if ( id < 0 ) null;
    if ( id >= player_ranks.length() ) return null;
    return player_ranks[id];
}

//------------------------------------------------------------------------------------------------------------------------//

PlayerRank @GrabPlayerRank( int client_pos )
{
    for ( uint i = 0; i < player_ranks.length(); i++ )
    {
        PlayerRank @handle = player_ranks[i];
        if ( handle is null ) continue;
        if ( client_pos == handle.rank ) return handle;
    }
    return null;
}
