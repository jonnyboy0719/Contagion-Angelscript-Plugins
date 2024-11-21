///===========================================================
///===========================================================
// Networked Data
///===========================================================
///===========================================================

// Our network data info
// NetObject structure:
//	>> Int		| target
//	>> Int		| server_ban
//	>> Int		| print_msg
void SBans_CheckBanStatus( NetObject@ pData )
{
	// Make sure we are connected to the database
	if ( hConnection is null ) return;
    // Make sure we aren't invalid
    if ( pData is null ) return;

    int iEntIndex = 0;
    bool bServerBan = false;
    bool bPrintMsg = false;
	string strQueryStatement;

	// Player index
    if ( pData.HasIndexValue( 0 ) )
        iEntIndex = pData.GetInt( 0 );

	// BanCheck
    if ( pData.HasIndexValue( 1 ) )
        bServerBan = pData.GetInt( 1 ) == 1 ? true : false;

	// Should print check
    if ( pData.HasIndexValue( 2 ) )
        bPrintMsg = pData.GetInt( 2 ) == 1 ? true : false;

	// Convert to pPlayer
	CTerrorPlayer@ pPlayer = ToTerrorPlayer( iEntIndex );

	// Format it
	string strSteamID32 = Utils.Steam64ToSteam32( pPlayer.GetSteamID64() );
	string strSteamID32_Formated = Utils.StrReplace( strSteamID32, "STEAM_0:", "" );

	if ( !bServerBan )
	{
		strQueryStatement = "SELECT authid, type FROM " + GrabDatabasePrefix() + "_comms WHERE authid REGEXP '^STEAM_[0-9]:" + strSteamID32_Formated + "$' AND (length = '0' OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL";
		// We are grabbing multiple rows, so let's make sure bMultipleResults is set to true!
		if ( bPrintMsg )
			SQL::SendQuery( hConnection, strQueryStatement, SBans_CheckBanStatus_Notify );
		else
			SQL::SendQuery( hConnection, strQueryStatement, SBans_CheckBanStatus );
	}
	else
	{
		strQueryStatement = "SELECT authid FROM " + GrabDatabasePrefix() + "_bans WHERE ((type = 0 AND authid REGEXP '^STEAM_[0-9]:" + strSteamID32_Formated+ "$') OR (type = 1 AND ip = '" + pPlayer.GrabIP() + "')) AND (length = '0' OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL";
		// We are grabbing multiple rows, so let's make sure bMultipleResults is set to true!
		SQL::SendQuery( hConnection, strQueryStatement, SBans_CheckBanStatus_ServerBan );
	}
}

//------------------------------------------------------------------------------------------------------------------------//

void SBans_CheckBanStatus_Notify( IMySQL@ hQuery )
{
	if ( hQuery is null ) return;
	// Make sure we have no errors
	if ( !hQuery.Failed() )
	{
		string strType = "";
		bool bGagged = false;
		bool bMuted = false;
		CTerrorPlayer @pPlayer = null;
		string player_name = "";

		while( SQL::NextResult( hQuery ) )
		{
			string strAuthID = SQL::ReadResult::GetString( hQuery, "authid" );
			int iType = SQL::ReadResult::GetInt( hQuery, "type" );

			if ( iType == 1 )
			{
				bGagged = true;
				strType = Translate::GrabTranslation( GetLanguage(), "SB_Gagged" );
			}
			if ( iType == 2 )
			{
				bMuted = true;
				strType = Translate::GrabTranslation( GetLanguage(), "SB_Muted" );
			}

			// Grab the player
			@pPlayer = GetPlayerBySteamID( strAuthID );
			if ( pPlayer is null )
				player_name = strAuthID;
			else
				player_name = pPlayer.GetPlayerName();
		}

		// Check if the player wsa muted, and also gagged.
		if ( bGagged && bMuted )
			strType = Translate::GrabTranslation( GetLanguage(), "SB_Silenced" );

		// Sourcebans read gag as chat, and mute as voice.
		// While we have gag as voice, and mute as chat (Built in admin system)
		AdminSystem.Gag( pPlayer, bGagged ? 0 : 1, false, "Communication ban trough SourceBans++" );
		AdminSystem.Mute( pPlayer, bMuted ? 0 : 1, false, "Communication ban trough SourceBans++" );

		if ( bGagged || bMuted )
			SBans_SendTextAll( Translate::GrabTranslationFormat( GetLanguage(), "SB_Formated_MuteGag", { player_name, strType } ) );
	}
}

//------------------------------------------------------------------------------------------------------------------------//

void SBans_CheckBanStatus( IMySQL@ hQuery )
{
	if ( hQuery is null ) return;
	// Make sure we have no errors
	if ( !hQuery.Failed() )
	{
		bool bGagged = false;
		bool bMuted = false;
		CTerrorPlayer @pPlayer = null;

		while( SQL::NextResult( hQuery ) )
		{
			string strAuthID = SQL::ReadResult::GetString( hQuery, "authid" );
			int iType = SQL::ReadResult::GetInt( hQuery, "type" );

			if ( iType == 1 )
				bGagged = true;
			if ( iType == 2 )
				bMuted = true;

			// Grab the player
			@pPlayer = GetPlayerBySteamID( strAuthID );
		}

		// Sourcebans read gag as chat, and mute as voice.
		// While we have gag as voice, and mute as chat (Built in admin system)
		AdminSystem.Gag( pPlayer, bGagged ? 0 : 1, false, "Communication ban trough SourceBans++" );
		AdminSystem.Mute( pPlayer, bMuted ? 0 : 1, false, "Communication ban trough SourceBans++" );
	}
}

//------------------------------------------------------------------------------------------------------------------------//

void SBans_CheckBanStatus_ServerBan( IMySQL@ hQuery )
{
	if ( hQuery is null ) return;
	// Make sure we have no errors
	if ( !hQuery.Failed() )
	{
		string strQueryStatement;
		string strSteamID32;
		string strSteamID32_Formated;
		CTerrorPlayer@ pPlayer = null;
		while( SQL::NextResult( hQuery ) )
		{
			@pPlayer = GetPlayerBySteamID( SQL::ReadResult::GetString( hQuery, 0 ) );
			string strSteamID = pPlayer.GetSteamID64();
			strSteamID32 = Utils.Steam64ToSteam32( strSteamID );
			strSteamID32_Formated = Utils.StrReplace( strSteamID32, "STEAM_0:", "" );
			
			if ( pPlayer !is null )
			{
				if ( GrabServerID() == -1 )
				{
					strQueryStatement = "INSERT INTO " + GrabDatabasePrefix() + "_banlog (sid ,time ,name ,bid) VALUES ";
					strQueryStatement += "((SELECT sid FROM " + GrabDatabasePrefix() + "_servers WHERE ip = '" + Utils.GetServerIP() + "' AND port = '" + GetHostPort() + "' LIMIT 0,1), UNIX_TIMESTAMP(), '" + Utils.EscapeCharacters( pPlayer.GetPlayerName() ) + "', ";
					strQueryStatement += "(SELECT bid FROM " + GrabDatabasePrefix() + "_bans WHERE ((type = 0 AND authid REGEXP '^STEAM_[0-9]:" + strSteamID32_Formated + "$') OR (type = 1 AND ip = '" + pPlayer.GrabIP() + "')) AND RemoveType IS NULL LIMIT 0,1))";
				}
				else
				{
					strQueryStatement = "INSERT INTO " + GrabDatabasePrefix() + "_banlog (sid ,time ,name ,bid) VALUES ";
					strQueryStatement += "(" + GrabServerID() + ", UNIX_TIMESTAMP(), '" + Utils.EscapeCharacters( pPlayer.GetPlayerName() ) + "', ";
					strQueryStatement += "(SELECT bid FROM " + GrabDatabasePrefix() + "_bans WHERE ((type = 0 AND authid REGEXP '^STEAM_[0-9]:" + strSteamID32_Formated + "$') OR (type = 1 AND ip = '" + pPlayer.GrabIP() + "')) AND RemoveType IS NULL LIMIT 0,1))";
				}

				// Send a new query, this time, ignore any callback etc
				SQL::SendAndIgnoreQuery( hConnection, strQueryStatement );

				string strPlayerName = pPlayer.GetPlayerName();
				AdminSystem.Kick( pPlayer, Translate::GrabTranslationFormat( GetLanguage(), "SB_Formated_JoinBanned", { GrabServerWebsite() } ) );

				SBans_SendTextAll( Translate::GrabTranslationFormat( GetLanguage(), "SB_Formated_JoinKick", { strPlayerName } ) );
				break;
			}
		}
	}
}

//------------------------------------------------------------------------------------------------------------------------//

// Our network data info
// NetObject structure:
//	>> Int		| admin
//	>> Int		| commtype
//	>> Int		| target
void SBans_CreateCommUnBan( NetObject@ pData )
{
	// Make sure we are connected to the database
	if ( hConnection is null ) return;
    // Make sure we aren't invalid
    if ( pData is null ) return;
	// Make sure the server ID is valid
	if ( GrabServerID() == -1 ) return;

	int iEntIndex;
	int iCommType;
	int iTargetIndex;

	// Admin index
    if ( pData.HasIndexValue( 0 ) )
        iEntIndex = pData.GetInt( 0 );

	// Comm Type
    if ( pData.HasIndexValue( 1 ) )
        iCommType = pData.GetInt( 1 );

	// Target Index
    if ( pData.HasIndexValue( 2 ) )
        iTargetIndex = pData.GetInt( 2 );

	// Convert to pPlayer
	CTerrorPlayer@ pAdmin = ToTerrorPlayer( iEntIndex );
	CTerrorPlayer@ pTarget = ToTerrorPlayer( iTargetIndex );

	// Sourcebans read gag as chat, and mute as voice.
	// While we have gag as voice, and mute as chat (Built in admin system)
	switch( iCommType )
	{
		case 0:
		{
			DoCommUnBan( pAdmin, pTarget, 1 );
			DoCommUnBan( pAdmin, pTarget, 2 );
		}
		break;

		case 1:
			DoCommUnBan( pAdmin, pTarget, 1 );
		break;

		case 2:
			DoCommUnBan( pAdmin, pTarget, 2 );
		break;
	}

	// Print message
	string strType = "{cyan}";
	switch( iCommType )
	{
		case 0:
			strType += Translate::GrabTranslation( GetLanguage(), "SB_UnSilenced" );
		break;

		case 1:
			strType += Translate::GrabTranslation( GetLanguage(), "SB_UnGagged" );
		break;

		case 2:
			strType += Translate::GrabTranslation( GetLanguage(), "SB_UnMuted" );
		break;
	}

	// Print message
	string strResult = Translate::GrabTranslationFormat( GetLanguage(), "SB_Formated_MsgShort", { Utils.EscapeCharacters( pTarget.GetPlayerName() ), strType } );
	SBans_SendTextAll( strResult );

	// Log the stuff
	Log.ToLocation( "sourcebans", LOGTYPE_INFO, "CreateCommUnBan: " + strResult );
}

//------------------------------------------------------------------------------------------------------------------------//

// Our network data info
// NetObject structure:
//	>> Int		| admin
//	>> Int		| commtype
//	>> Int		| target
//	>> Int		| time
//	>> String	| reason
void SBans_CreateCommBan( NetObject@ pData )
{
	// Make sure we are connected to the database
	if ( hConnection is null ) return;
    // Make sure we aren't invalid
    if ( pData is null ) return;
	// Make sure the server ID is valid
	if ( GrabServerID() == -1 ) return;

	int iEntIndex;
	int iTargetIndex;
	int iCommType;
	int time;
	string reason;

	// Admin index
    if ( pData.HasIndexValue( 0 ) )
        iEntIndex = pData.GetInt( 0 );

	// Comm Type
    if ( pData.HasIndexValue( 1 ) )
        iCommType = pData.GetInt( 1 );

	// Target Index
    if ( pData.HasIndexValue( 2 ) )
        iTargetIndex = pData.GetInt( 2 );

	// Time
    if ( pData.HasIndexValue( 3 ) )
        time = pData.GetInt( 3 );

	// Reason
    if ( pData.HasIndexValue( 4 ) )
        reason = Utils.EscapeCharacters( pData.GetString( 4 ) );

	// Convert to pPlayer
	CTerrorPlayer@ pAdmin = ToTerrorPlayer( iEntIndex );
	CTerrorPlayer@ pTarget = ToTerrorPlayer( iTargetIndex );

	switch( iCommType )
	{
		case 0:
		{
			DoCommBan( pAdmin, pTarget, 1, time, reason );
			DoCommBan( pAdmin, pTarget, 2, time, reason );
		}
		break;

		case 1:
			DoCommBan( pAdmin, pTarget, 1, time, reason );
		break;

		case 2:
			DoCommBan( pAdmin, pTarget, 2, time, reason );
		break;
	}

	///===========================================================
	// Print Message
	string strTime;
	string strResult;
	string strType = Translate::GrabTranslation( GetLanguage(), "SB_Silenced" );
	string Name = Utils.EscapeCharacters( pTarget.GetPlayerName() );

	if ( iCommType == 1 )
		strType = Translate::GrabTranslation( GetLanguage(), "SB_Gagged" );
	else if ( iCommType == 2 )
		strType = Translate::GrabTranslation( GetLanguage(), "SB_Muted" );

	if ( time > 0 )
	{
		strTime = "{red}" + time + "{default}";
		if ( time > 1 )
			strTime += " Minutes";
		else
			strTime += " Minute";
		strResult = Translate::GrabTranslationFormat( GetLanguage(), "SB_Formated_Msg", { Name, strType, strTime } );
	}
	else
		strResult = Translate::GrabTranslationFormat( GetLanguage(), "SB_Formated_Msg_Perma", { Name, strType } );

	// Reason
	strResult += "\n" + Translate::GrabTranslationFormat( GetLanguage(), "SB_Formated_Msg_Reason", { reason } );

	SBans_SendTextAll( strResult );
	// END Print Message
	///===========================================================

	// Log the stuff
	Log.ToLocation( "sourcebans", LOGTYPE_INFO, "CreateCommBan: " + strResult );
}

//------------------------------------------------------------------------------------------------------------------------//

// Our network data info
// NetObject structure:
//	>> Int		| admin
//	>> Int		| target
//	>> Int		| time
//	>> String	| reason
void SBans_CreateBan( NetObject@ pData )
{
	// Make sure we are connected to the database
	if ( hConnection is null ) return;
    // Make sure we aren't invalid
    if ( pData is null ) return;

	int iEntIndex;
	int iTargetIndex;
	int time;
	string reason;

	// Admin index
    if ( pData.HasIndexValue( 0 ) )
        iEntIndex = pData.GetInt( 0 );

	// Target Index
    if ( pData.HasIndexValue( 1 ) )
        iTargetIndex = pData.GetInt( 1 );

	// Time
    if ( pData.HasIndexValue( 2 ) )
        time = pData.GetInt( 2 );

	// Reason
    if ( pData.HasIndexValue( 3 ) )
        reason = Utils.EscapeCharacters( pData.GetString( 3 ) );

	// Convert to pPlayer
	CTerrorPlayer@ pAdmin = ToTerrorPlayer( iEntIndex );
	CTerrorPlayer@ pTarget = ToTerrorPlayer( iTargetIndex );

	// Admin information
	string adminIP;
	string adminSteamID;

	// The server is the one calling the ban
	if ( pAdmin is null )
	{
		// setup dummy adminAuth and adminIp for server
		adminIP = "STEAM_ID_SERVER";
		adminSteamID = Utils.GetServerIP();
	}
	else
	{
		adminIP = pAdmin.GrabIP();
		adminSteamID = Utils.Steam64ToSteam32( pAdmin.GetSteamID64() );
	}

	string adminSteamID_Formated = Utils.StrReplace( adminSteamID, "STEAM_0:", "" );

	// Target information
	string IP;
	string SteamID;
	string Name;

	IP = pTarget.GrabIP();
	SteamID = Utils.Steam64ToSteam32( pTarget.GetSteamID64() );
	Name = Utils.EscapeCharacters( pTarget.GetPlayerName() );

	string strQueryStatement;
	if ( GrabServerID() == -1 )
	{
		strQueryStatement = "INSERT INTO " + GrabDatabasePrefix() + "_bans (ip, authid, name, created, ends, length, reason, aid, adminIp, sid, country) VALUES ";
		strQueryStatement += "('" + IP + "', '" + SteamID + "', '" + Name + "', UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + " + (time * 60) + ", " + (time * 60) + ", '" + reason + "', IFNULL((SELECT aid FROM " + GrabDatabasePrefix() + "_admins WHERE authid = '" + adminSteamID + "' OR authid REGEXP '^STEAM_[0-9]:" + adminSteamID_Formated + "$'),'0'), '" + adminIP + "', ";
		strQueryStatement += "(SELECT sid FROM " + GrabDatabasePrefix() + "_servers WHERE ip = '" + Utils.GetServerIP() + "' AND port = '" + GetHostPort() + "' LIMIT 0,1), ' ')";
	}
	else
	{
		strQueryStatement = "INSERT INTO " + GrabDatabasePrefix() + "_bans (ip, authid, name, created, ends, length, reason, aid, adminIp, sid, country) VALUES ";
		strQueryStatement += "('" + IP + "', '" + SteamID + "', '" + Name + "', UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + " + (time * 60) + ", " + (time * 60) + ", '" + reason + "', IFNULL((SELECT aid FROM " + GrabDatabasePrefix() + "_admins WHERE authid = '" + adminSteamID + "' OR authid REGEXP '^STEAM_[0-9]:" + adminSteamID_Formated + "$'),'0'), '" + adminIP + "', " + GrabServerID() + ", ' ')";
	}

	SQL::SendAndIgnoreQuery( hConnection, strQueryStatement );

	///===========================================================
	// Print Message
	string strTime;
	string strResult;
	string strType = Translate::GrabTranslation( GetLanguage(), "SB_Banned" );
	if ( time > 0 )
	{
		strTime = "{red}" + time + "{default}";
		if ( time > 1 )
			strTime += " Minutes";
		else
			strTime += " Minute";
		strResult = Translate::GrabTranslationFormat( GetLanguage(), "SB_Formated_Msg", { Name, strType, strTime } );
	}
	else
		strResult = Translate::GrabTranslationFormat( GetLanguage(), "SB_Formated_Msg_Perma", { Name, strType } );

	// Reason
	strResult += "\n" + Translate::GrabTranslationFormat( GetLanguage(), "SB_Formated_Msg_Reason", { reason } );

	// Kick the player before we print the msg
	AdminSystem.Kick( pTarget, strResult );

	SBans_SendTextAll( strResult );
	// END Print Message
	///===========================================================

	// Log the stuff
	Log.ToLocation( "sourcebans", LOGTYPE_INFO, "CreateBan: " + strResult );
}

//------------------------------------------------------------------------------------------------------------------------//

// Our network data info
// NetObject structure:
//	>> Int		| admin
//	>> String	| steamid
//	>> Int		| time
//	>> String	| reason
void SBans_CreateIDBan( NetObject@ pData )
{
	// Make sure we are connected to the database
	if ( hConnection is null ) return;
    // Make sure we aren't invalid
    if ( pData is null ) return;

	int iEntIndex;
	string SteamID;
	int time;
	string reason;

	// Admin index
    if ( pData.HasIndexValue( 0 ) )
        iEntIndex = pData.GetInt( 0 );

	// Target Index
    if ( pData.HasIndexValue( 1 ) )
        SteamID = pData.GetString( 1 );

	// Time
    if ( pData.HasIndexValue( 2 ) )
        time = pData.GetInt( 2 );

	// Reason
    if ( pData.HasIndexValue( 3 ) )
        reason = Utils.EscapeCharacters( pData.GetString( 3 ) );

	// Convert to pPlayer
	CTerrorPlayer@ pAdmin = ToTerrorPlayer( iEntIndex );

	// Admin information
	string adminIP;
	string adminSteamID;

	// The server is the one calling the ban
	if ( pAdmin is null )
	{
		// setup dummy adminAuth and adminIp for server
		adminIP = "STEAM_ID_SERVER";
		adminSteamID = Utils.GetServerIP();
	}
	else
	{
		adminIP = pAdmin.GrabIP();
		adminSteamID = Utils.Steam64ToSteam32( pAdmin.GetSteamID64() );
	}

	string adminSteamID_Formated = Utils.StrReplace( adminSteamID, "STEAM_0:", "" );

	// Target information
	string Name;

	Name = SteamID;

	string strQueryStatement;
	if ( GrabServerID() == -1 )
	{
		strQueryStatement = "INSERT INTO " + GrabDatabasePrefix() + "_bans (authid, name, created, ends, length, reason, aid, adminIp, sid, country) VALUES ";
		strQueryStatement += "('" + SteamID + "', '" + Name + "', UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + " + (time * 60) + ", " + (time * 60) + ", '" + reason + "', IFNULL((SELECT aid FROM " + GrabDatabasePrefix() + "_admins WHERE authid = '" + adminSteamID + "' OR authid REGEXP '^STEAM_[0-9]:" + adminSteamID_Formated + "$'),'0'), '" + adminIP + "', ";
		strQueryStatement += "(SELECT sid FROM " + GrabDatabasePrefix() + "_servers WHERE ip = '" + Utils.GetServerIP() + "' AND port = '" + GetHostPort() + "' LIMIT 0,1), ' ')";
	}
	else
	{
		strQueryStatement = "INSERT INTO " + GrabDatabasePrefix() + "_bans (authid, name, created, ends, length, reason, aid, adminIp, sid, country) VALUES ";
		strQueryStatement += "('" + SteamID + "', '" + Name + "', UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + " + (time * 60) + ", " + (time * 60) + ", '" + reason + "', IFNULL((SELECT aid FROM " + GrabDatabasePrefix() + "_admins WHERE authid = '" + adminSteamID + "' OR authid REGEXP '^STEAM_[0-9]:" + adminSteamID_Formated + "$'),'0'), '" + adminIP + "', " + GrabServerID() + ", ' ')";
	}

	SQL::SendAndIgnoreQuery( hConnection, strQueryStatement );

	///===========================================================
	// Print Message
	string strTime;
	string strResult;
	string strType = Translate::GrabTranslation( GetLanguage(), "SB_Banned" );
	if ( time > 0 )
	{
		strTime = "{red}" + time + "{default}";
		if ( time > 1 )
			strTime += " Minutes";
		else
			strTime += " Minute";
		strResult = Translate::GrabTranslationFormat( GetLanguage(), "SB_Formated_Msg", { Name, strType, strTime } );
	}
	else
		strResult = Translate::GrabTranslationFormat( GetLanguage(), "SB_Formated_Msg_Perma", { Name, strType } );

	// Reason
	strResult += "\n" + Translate::GrabTranslationFormat( GetLanguage(), "SB_Formated_Msg_Reason", { reason } );

	SBans_SendTextAll( strResult );
	// END Print Message
	///===========================================================

	// Log the stuff
	Log.ToLocation( "sourcebans", LOGTYPE_INFO, "CreateIDBan: " + strResult );
}
