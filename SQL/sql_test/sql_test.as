
CSQLConnection@ gMainConnection = null;

void OnPluginInit()
{
	PluginData::SetName( "SQL Test" );
	Events::Player::PlayerSay.Hook( @PlayerSay );
	Events::Player::OnPlayerEscape.Hook( @OnPlayerEscape );
	ConnectToDB();
}

//------------------------------------------------------------------------------------------------------------------------//

void OnPluginUnload()
{
	// Make sure this is disconnected!
	SQL::Disconnect( gMainConnection );
}

//------------------------------------------------------------------------------------------------------------------------//

void OnMapShutdown()
{
	// Map is being shutdown, disconnect our connection, as it won't remember the connection once we shutdown the map
	// The reason is due we don't want to send, or retrieve SQL data while we are loading map information.
	SQL::Disconnect( gMainConnection );
}

//------------------------------------------------------------------------------------------------------------------------//

void OnMapInit()
{
	// Load it, since the connection gets killed on map shutdown
	@gMainConnection = null;
	ConnectToDB();
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode PlayerSay( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	string arg1 = pArgs.Arg( 1 );
	if ( Utils.StrEql( arg1, "!q1" ) )
	{
		QueryTest();
		return HOOK_HANDLED;
	}
	else if ( Utils.StrEql( arg1, "!q2" ) )
	{
		if ( gMainConnection is null ) return HOOK_HANDLED;
		SQL::SendAndIgnoreQuery(
			gMainConnection,
			"UPDATE `example_table` SET `authid` = " + 100 + ", `health` = " + 5 + " WHERE `name` = 'foobar';"
		);
		return HOOK_HANDLED;
	}
	else if ( Utils.StrEql( arg1, "!q3" ) )
	{
		if ( gMainConnection is null ) return HOOK_HANDLED;
		SQL::SendQuery(
			gMainConnection,
			"INSERT INTO example_table (authid, health, name)\n"
			"VALUES (420, 100, 'Norway');"
		);
		SQL::SendAndIgnoreQuery(
			gMainConnection,
			"INSERT INTO example_table (authid, health, name)\n"
			"VALUES (9005, 15, 'Larry');"
		);
		SQL::SendAndIgnoreQuery(
			gMainConnection,
			"INSERT INTO example_table (authid, health, name)\n"
			"VALUES (55, 500, 'foobar');"
		);
		return HOOK_HANDLED;
	}
	else if ( Utils.StrEql( arg1, "!q4" ) )
	{
		if ( gMainConnection is null ) return HOOK_HANDLED;
		SQL::SendQuery(
			gMainConnection,
			"INSERT INTO example_table (authid, health, name)\n"
			"VALUES (55, 500, 'foobar');"
		);
		return HOOK_HANDLED;
	}
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerEscape( CTerrorPlayer@ pPlayer )
{
	RecordEscape(pPlayer);
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

void ConnectToDB()
{
	// SQL Connection info
	string strSQLHost = "localhost"; // Our hostname
	int iPort = 0; // if iPort is 0, then it will use default MySQL port
	string strSQLUser = "root"; // Our username
	string strSQLPass = ""; // Our password
	string strSQLDB = "test_db"; // Our database

	// Create our connection
	SQL::Connect( strSQLHost, iPort, strSQLUser, strSQLPass, strSQLDB, OnSQLConnect );
}

//------------------------------------------------------------------------------------------------------------------------//

void QueryTest()
{
	if ( gMainConnection is null ) return;

	// Our query
	string strQuery = "SELECT id, health, name FROM `example_table` WHERE (`name` = 'foobar')";

	Log.PrintToServerConsole( LOGTYPE_INFO, "strQuery: " + strQuery );

	// Send our query!
	SQL::SendQuery( gMainConnection, strQuery, TestQuery );
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

//------------------------------------------------------------------------------------------------------------------------//

void TestQuery( IMySQL@ pQuery )
{
	// If our query is null, then it failed.
	if ( pQuery is null ) return;

	// That means the table does not exist. Let's create our table then.
	if ( pQuery.Failed() )
	{
		string strQuery = "CREATE TABLE IF NOT EXISTS `example_table` ("
			"`id` int(11) NOT NULL auto_increment,"
			"`authid` int(11) NOT NULL default '0',"
			"`health` int(11) NOT NULL default '0',"
			"`name` varchar(250)  NOT NULL default '',"
			"PRIMARY KEY  (`id`)"
		");";
		SQL::SendAndIgnoreQuery( gMainConnection, strQuery );
		return;
	}

	int iID = SQL::ReadResult::GetInt( pQuery, 0 );
	int iHealth = SQL::ReadResult::GetInt( pQuery, "health" );
	string strName = SQL::ReadResult::GetString( pQuery, "name" );

	// Print our results
	Log.PrintToServerConsole(
		LOGTYPE_INFO,
		"ID: " + iID
		+ " | Health: " + iHealth
		+ " | Name: " + strName
	);
}

//------------------------------------------------------------------------------------------------------------------------//

void RecordEscape( CTerrorPlayer @pPlayer )
{
	if ( pPlayer is null ) return;
	if ( gMainConnection is null ) return;
	// First query is to insert a record, if we don't exist.
	SQL::SendQuery(
		gMainConnection,
		"INSERT INTO record (steamid, name, escpaceCount, money)\n"
		"SELECT '" + pPlayer.GetSteamID64() + "', '" + pPlayer.GetPlayerName() + "', 0, 100\n"
		"WHERE NOT EXISTS (SELECT * FROM record WHERE steamid = '" + pPlayer.GetSteamID64() + "')"
	);
	// Second query will select it (will be fired after the first one)
	SQL::SendQuery(
		gMainConnection,
		"SELECT * FROM record WHERE steamid = '" + pPlayer.GetSteamID64() + "'",
		Query_RecordPlayer
	);
}

//------------------------------------------------------------------------------------------------------------------------//

void Query_RecordPlayer( IMySQL@ pQuery )
{
	if ( pQuery is null ) return;
	if ( pQuery.Failed() ) return;
	Log.PrintToServerConsole( LOGTYPE_INFO, "Query_RecordPlayer >> pQuery >> Valid" );

	// Grab our escape counter, and increase it
	int iEscapeCount = SQL::ReadResult::GetInt( pQuery, "escpaceCount" );
	iEscapeCount++;

	Log.PrintToServerConsole( LOGTYPE_INFO, "Query_RecordPlayer >> id >> " + SQL::ReadResult::GetInt( pQuery, "id" ) );
	Log.PrintToServerConsole( LOGTYPE_INFO, "Query_RecordPlayer >> steamid >> " + SQL::ReadResult::GetString( pQuery, "steamid" ) );
	Log.PrintToServerConsole( LOGTYPE_INFO, "Query_RecordPlayer >> name >> " + SQL::ReadResult::GetString( pQuery, "name" ) );
	Log.PrintToServerConsole( LOGTYPE_INFO, "Query_RecordPlayer >> escpaceCount >> " + iEscapeCount );
	Log.PrintToServerConsole( LOGTYPE_INFO, "Query_RecordPlayer >> money >> " + SQL::ReadResult::GetInt( pQuery, "money" ) );

	// Grab our steamid (either from SELECT or the INSERT INTO)
	CTerrorPlayer @pPlayer = GetPlayerBySteamID( SQL::ReadResult::GetString( pQuery, "steamid" ) );

	if ( pPlayer is null ) return;

	// Now, let's update it!
	SQL::SendQuery(
		gMainConnection,
		"UPDATE record SET escpaceCount = " + iEscapeCount + " WHERE steamid = '" + pPlayer.GetSteamID64() + "';"
	);
}
