#include "geoip/core.as"

void OnPluginInit()
{
	PluginData::SetVersion( "1.1" );
	PluginData::SetAuthor( "JonnyBoy0719" );
	PluginData::SetName( "Connection Announcer" );
	Events::Player::OnPlayerConnected.Hook( @OnPlayerConnected );
	Events::Player::OnPlayerDisconnected.Hook( @OnPlayerDisconnected );
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerConnected( CTerrorPlayer@ pPlayer )
{
	OnPlayerConnection( pPlayer, true );
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerDisconnected( CTerrorPlayer@ pPlayer )
{
	OnPlayerConnection( pPlayer, false );
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

void OnPlayerConnection( CTerrorPlayer@ pPlayer, const bool &in bConnected )
{
	// Grab the IP (but get rid of the port)
	string ipLoc = pPlayer.GrabIP();
	CASCommand @args = StringToArgSplit( ipLoc, ":" );
	string conLocation = GeoIP::GrabLocation( args.Arg( 0 ) );

	// Did we connect or disconnect?
	string conString = bConnected ? "{green}connected" : "{red}disconnected";
	if ( !pPlayer.IsBot() )
		conString += " {white}from {community}" + conLocation;

	// Grab our SteamID
	string steamid = Utils.Convert( STEAMID32, pPlayer.GetSteamID64() );

	// If this is a bot, then change the steamid with the ipLoc (it will say BOT)
	if ( pPlayer.IsBot() ) steamid = ipLoc;

	// Print to our admins and normal players
	PrintToAdmins(
		"{arcana}" + pPlayer.GetPlayerName() + " {gold}[{greenyellow}" + steamid + "{gold}] {white}has " + conString,
		pPlayer.IsBot() ? "" : " {gold}[{greenyellow}" + ipLoc + "{gold}]"
	);
}

//------------------------------------------------------------------------------------------------------------------------//

void PrintToAdmins( const string &in strMsg, const string &in strAdminMsg )
{
	for ( int x = 1; x <= Globals.GetMaxClients(); x++ )
	{
		CTerrorPlayer @pPlayer = ToTerrorPlayer( x );
		if ( pPlayer is null ) continue;
		if ( !pPlayer.IsConnected() ) continue;
		if ( AdminSystem.AdminExist( pPlayer ) && !Utils.StrEql( strAdminMsg, "" ) )
			Chat.PrintToChat( pPlayer, strMsg + strAdminMsg );
		else
			Chat.PrintToChat( pPlayer, strMsg );
	}
}