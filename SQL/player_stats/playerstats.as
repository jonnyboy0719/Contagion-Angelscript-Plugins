CSQLConnection@ gMainConnection = null;
bool g_HasAPlayerDied = false;

// Gamemodes
const int GM_NONE = 0;              // If our gamemode wasn't found, or just dev_ maps
const int GM_ESCAPE = 1;            // Escape maps (ce_)
const int GM_EXTRACTION = 2;        // Extraction maps (cx_)
const int GM_FLATLINE = 3;          // Flatline maps (cf_)
const int GM_HUNTED = 4;            // Hunted maps (ch_)
const int GM_PANIC = 5;             // Panic maps (cp_)

//------------------------------------------------------------------------------------------------------------------------//

#include "playerstats/hooks/player_escape"
#include "playerstats/hooks/player_say"
#include "playerstats/hooks/player_killed"
#include "playerstats/hooks/player_damaged"
#include "playerstats/hooks/player_connect"
#include "playerstats/hooks/player_infect"
#include "playerstats/hooks/infected_killed"
#include "playerstats/hooks/weapon_medkit"
#include "playerstats/hooks/weapon_inoculator"
#include "playerstats/menu"
#include "playerstats/update_player"
#include "playerstats/player_rank"
#include "playerstats/game_events"
#include "playerstats/convars"
#include "geoip/core.as"

//------------------------------------------------------------------------------------------------------------------------//
// Interface
#include "admin/shared/interface.as"

//------------------------------------------------------------------------------------------------------------------------//
// Import
import void AdminMenu_RegisterItem( IAdminMenuItemBase @module ) from "adminmenu.as";
import void AdminMenu_RemoveItem( string module_id ) from "adminmenu.as";
import void AdminMenu_BackToGroup( CTerrorPlayer@ pPlayer, int group ) from "adminmenu.as";

//------------------------------------------------------------------------------------------------------------------------//

void OnPluginInit()
{
    PluginData::SetVersion( "1.0.0" );
    PluginData::SetAuthor( "Wuffesan" );
    PluginData::SetName( "Player Stats" );
    
    // Make sure adminmenu is loaded
    if ( !PluginData::IsLoaded( "adminmenu" ) )
    {
        throw( "Player Stats plugin requires \"adminmenu\" to be fully loaded!" );
        return;
    }

    // Hooks
    Events::Player::OnPlayerEscape.Hook( @OnPlayerEscape );
    Events::Player::PlayerSay.Hook( @OnPlayerSay );
    Events::Player::OnPlayerKilled.Hook( @OnPlayerKilled );
    Events::Player::OnPlayerDamaged.Hook( @OnPlayerDamaged );
    Events::Player::OnPlayerConnected.Hook( @OnPlayerConnected );
    Events::Player::OnPlayerDisconnected.Hook( @OnPlayerDisconnected );
    Events::Player::OnPlayerInfectedEx.Hook( @OnPlayerInfectedEx );
    Events::Weapons::FirstAidHeal.Hook( @FirstAidHeal );
    Events::Weapons::InoculatorHeal.Hook( @InoculatorHeal );
    Events::Infected::OnInfectedKilled.Hook( @OnInfectedKilled );
    
    // Make sure the cvars are registered by the engine
    RegisterConvars();
    
    // Connect to the DB
    ConnectToDB();
    
    // Init our menu
    Menu::OnInit();
    
    // Register our events
    RegisterEvents();
}

//------------------------------------------------------------------------------------------------------------------------//

void OnPluginUnload()
{
    // Make sure this is disconnected!
    SQL::Disconnect( gMainConnection );
    
    // Unload our crap
    Menu::OnUnload();
    UnRegisterConvars();
}

//------------------------------------------------------------------------------------------------------------------------//

void OnMapShutdown()
{
    // Map is being shutdown, disconnect our connection, as it won't remember the connection once we shutdown the map
    // The reason is due we don't want to send, or retrieve SQL data while we are loading map information.
    SQL::Disconnect( gMainConnection );
    g_HasAPlayerDied = false;
}

//------------------------------------------------------------------------------------------------------------------------//

void OnMapInit()
{
    // Load it, since the connection gets killed on map shutdown
    @gMainConnection = null;
    g_HasAPlayerDied = false;
    ConnectToDB();
}

//------------------------------------------------------------------------------------------------------------------------//

void ConnectToDB()
{
    // SQL Connection info
    // Our hostname
    string strSQLHost = "localhost";
    // if iPort is 0, then it will use default MySQL port
    int iPort         = 0;
    // Our username
    string strSQLUser = "root";
    // Our password
    string strSQLPass = "";
    // Our database
    string strSQLDB   = "player_stats";

    // Create our connection
    SQL::Connect( strSQLHost, iPort, strSQLUser, strSQLPass, strSQLDB, OnSQLConnect );
}

//------------------------------------------------------------------------------------------------------------------------//

void OnSQLConnect( CSQLConnection@ pConnection )
{
    // If our connection was a success, then we can save the CSQLConnection object to a local variable.
    // If not, stop here.
    if ( pConnection.Failed() ) return;

    // Apply our value
    @gMainConnection = pConnection;

    Log.PrintToServerConsole( LOGTYPE_INFO, "Connected to our SQL Database." );
}
