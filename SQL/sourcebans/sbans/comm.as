///===========================================================
///===========================================================
// Communication
///===========================================================
///===========================================================

void DoCommBan( CTerrorPlayer@ pAdmin, CTerrorPlayer@ pTarget, int iCommType, int time, string reason )
{
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
	strQueryStatement = "INSERT INTO " + GrabDatabasePrefix() + "_comms (authid, name, created, ends, length, reason, aid, adminIp, sid, type) ";
	strQueryStatement += "VALUES ('" + SteamID + "', '" + Name + "', UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + " + (time * 60) + ", " + (time * 60) + ", '" + reason + "', ";
	strQueryStatement += "IFNULL((SELECT aid FROM " + GrabDatabasePrefix() + "_admins WHERE authid = '" + adminSteamID + "' OR authid REGEXP '^STEAM_[0-9]:" + adminSteamID_Formated + "$'), '0'), '" + adminIP + "', " + GrabServerID() + ", " + iCommType + ")";

	SQL::SendAndIgnoreQuery( hConnection, strQueryStatement );

	if ( pTarget !is null )
	{
		// Mute, gag or silence the player
		if ( iCommType == 1 )
			AdminSystem.Gag( pTarget, 0, false, "Communication ban trough SourceBans++" );
		else if ( iCommType == 2 )
			AdminSystem.Mute( pTarget, 0, false, "Communication ban trough SourceBans++" );
	}
}

//------------------------------------------------------------------------------------------------------------------------//

void DoCommUnBan( CTerrorPlayer@ pAdmin, CTerrorPlayer@ pTarget, int iUnBanValue )
{
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
	string TypeWhere;

	IP = pTarget.GrabIP();
	SteamID = Utils.Steam64ToSteam32( pTarget.GetSteamID64() );
	Name = Utils.EscapeCharacters( pTarget.GetPlayerName() );

	string SteamID_Formated = Utils.StrReplace( SteamID, "STEAM_0:", "" );

	string strQueryStatement;
	strQueryStatement = "SELECT bid FROM " + GrabDatabasePrefix() + "_comms WHERE (type = " + iUnBanValue + " AND authid = '" + adminSteamID + "') AND (length = '0' OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL";

	SQL::SendQuery( hConnection, strQueryStatement, DoCommUnBanQuery );
}

//------------------------------------------------------------------------------------------------------------------------//

void DoCommUnBanQuery( IMySQL@ hQuery )
{
	if ( hQuery is null ) return;
	if ( !hQuery.Failed() )
	{
		while( SQL::NextResult( hQuery ) )
		{
			string strQueryStatement;
			strQueryStatement = "UPDATE " + GrabDatabasePrefix() + "_comms ";
			strQueryStatement += "SET RemovedBy = " + SQL::ReadResult::GetInt( hQuery, 1 ) + ",";
			strQueryStatement += "RemoveType = 'U',";
			strQueryStatement += "RemovedOn = UNIX_TIMESTAMP(),";
			strQueryStatement += "ureason = 'No Reason Was Given.'";
			strQueryStatement += "WHERE	bid = " + SQL::ReadResult::GetInt( hQuery, 0 ) + "";
			SQL::SendAndIgnoreQuery( hConnection, strQueryStatement );
		}
	}
}
