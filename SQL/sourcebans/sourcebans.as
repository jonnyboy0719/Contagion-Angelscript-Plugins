
///===========================================================
///===========================================================
// SourceBans for Contagion. Based on the ZPS version.
//		Written by Johan "JonnyBoy0719" Ehrendahl
///===========================================================
///===========================================================

#include "sbans/lang.as"
#include "sbans/cvars.as"
#include "sbans/net.as"
#include "sbans/comm.as"
#include "sbans/hooks.as"

//------------------------------------------------------------------------------------------------------------------------//

CSQLConnection@ hConnection = null;
JsonValues@ hJsonData = null;

//------------------------------------------------------------------------------------------------------------------------//

CBaseEntity@ ToBaseEntity( CTerrorPlayer@ pPlayer )
{
	CBasePlayer@ pBasePlayer = pPlayer.opCast();
	CBaseEntity@ pEntityPlayer = pBasePlayer.opCast();
	return pEntityPlayer;
}

//------------------------------------------------------------------------------------------------------------------------//

void OnPluginInit()
{
	// Plugin Data
	PluginData::SetVersion( "2.0" );
	PluginData::SetAuthor( "Johan \"JonnyBoy0719\" Ehrendahl" );
	PluginData::SetName( "SourceBans++" );

	// Add our translation file for SourceBans
	Translate::Init();
	Translate::AddTranslation( "sourcebans" );
	Translate::SetFile( "sourcebans" );

	// Read our json data
	ReadJsonFile();

	// Connect to our database
	SQL::Connect(
		FileSystem::GrabString( hJsonData, "Connection", "host" ),
		FileSystem::GrabInt( hJsonData, "Connection", "port" ),
		FileSystem::GrabString( hJsonData, "Connection", "user" ),
		FileSystem::GrabString( hJsonData, "Connection", "password" ),
		FileSystem::GrabString( hJsonData, "Connection", "database" ),
		OnSQLConnect
	);

	// Convar
	CreateConvars();

	// Hooks
	RegisterHooks();
}

//------------------------------------------------------------------------------------------------------------------------//

void OnSQLConnect( CSQLConnection@ pConnection )
{
	// If our connection was a success, then we can save the CSQLConnection object to a local variable.
	// If not, stop here.
	if ( pConnection.Failed() )
	{
		Log.PrintToServerConsole( LOGTYPE_CRITICAL, "Failed to connect to the SourceBans++ Database!" );
		return;
	}

	// Let's set a prefix, so we know it's from SourceBans
	SQL::SetErrorPrefix( pConnection, "SQL Error" );

	// Let's also override the location where we save the mysql errors at
	SQL::SetErrorLocation( pConnection, "sourcebans.log" );

	// We want to know the errors
	SQL::PrintErrorsOnIgnoreQuery( pConnection, true );

	// Apply our value
	@hConnection = pConnection;

	Log.PrintToServerConsole( LOGTYPE_INFO, "Connected to the SourceBans++ Database!" );
}

//------------------------------------------------------------------------------------------------------------------------//

string GetLanguage()
{
	return FileSystem::GrabString( hJsonData, "ServerInfo", "language" );
}

//------------------------------------------------------------------------------------------------------------------------//

void OnPluginUnload()
{
	SQL::Disconnect( hConnection );
	Translate::RemoveTranslation( "sourcebans" );
}

//------------------------------------------------------------------------------------------------------------------------//

void ReadJsonFile()
{
	@hJsonData = FileSystem::ReadFile( "sourcebans" );
	if ( hJsonData is null )
	{
		@hJsonData = FileSystem::CreateJson();

		FileSystem::Write( hJsonData, "Connection", "host", "localhost" );
		FileSystem::Write( hJsonData, "Connection", "user", "root" );
		FileSystem::Write( hJsonData, "Connection", "password", "" );
		FileSystem::Write( hJsonData, "Connection", "port", 0 );
		FileSystem::Write( hJsonData, "Connection", "database", "mydatabase" );
		FileSystem::Write( hJsonData, "Connection", "prefix", "sb" );

		FileSystem::Write( hJsonData, "ServerInfo", "language", "english" );
		FileSystem::Write( hJsonData, "ServerInfo", "id", -1 );
		FileSystem::Write( hJsonData, "ServerInfo", "website", "contagion-game.com" );

		FileSystem::CreateFile( "sourcebans", hJsonData );
	}
}

//------------------------------------------------------------------------------------------------------------------------//

int GrabServerID() { return FileSystem::GrabInt( hJsonData, "ServerInfo", "id" ); }
string GrabDatabasePrefix() { return FileSystem::GrabString( hJsonData, "Connection", "prefix" ); }
string GrabServerWebsite() { return FileSystem::GrabString( hJsonData, "ServerInfo", "website" ); }

//------------------------------------------------------------------------------------------------------------------------//

string GetPluginTag() {	return Translate::GrabTranslation( GetLanguage(), "SB_Tag" ); }

//------------------------------------------------------------------------------------------------------------------------//

void SBans_SendTextAll( string strMsg )
{
	Chat.PrintToChat( all, GetPluginTag() + " {default}" + strMsg );
}

//------------------------------------------------------------------------------------------------------------------------//

void SBans_SendTextToConsole( CTerrorPlayer@ pPlayer, string strMsg )
{
	if ( pPlayer is null )
	{
		// If player is null, log it instead
		Chat.PrintToConsole( GetPluginTag() + " {default}" + strMsg );
		return;
	}
	//CBasePlayer@ pPlayerEnt = pPlayer.opCast();	// Convert to CBasePlayer
	Chat.PrintToConsolePlayer( pPlayer, GetPluginTag() + " {default}" + strMsg );
}
