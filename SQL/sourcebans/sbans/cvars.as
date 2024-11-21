///===========================================================
///===========================================================
// Convars
///===========================================================
///===========================================================

string GetHostPort()
{
	CASConVarRef@ hostport = ConVar::Find( "hostport" );
	if ( hostport is null ) return "27015";
	return hostport.GetValue();
}

//------------------------------------------------------------------------------------------------------------------------//

void CreateConvars()
{
	ConCommand::Create( "sbans_ban", "SBans_ConCommand_Ban", "<#userid|name> <time|0> [reason]", LEVEL_MODERATOR );
	ConCommand::Create( "sbans_kick", "SBans_ConCommand_Kick", "<#userid|name> [reason]", LEVEL_MODERATOR );

	ConCommand::Create( "sbans_gag", "SBans_ConCommand_Gag", "<#userid|name> <time|0> [reason]", LEVEL_MODERATOR );
	ConCommand::Create( "sbans_mute", "SBans_ConCommand_Mute", "<#userid|name> <time|0> [reason]", LEVEL_MODERATOR );
	ConCommand::Create( "sbans_silence", "SBans_ConCommand_Silence", "<#userid|name> <time|0> [reason]", LEVEL_MODERATOR );

	ConCommand::Create( "sbans_ungag", "SBans_ConCommand_UnGag", "<#userid|name>", LEVEL_MODERATOR );
	ConCommand::Create( "sbans_unmute", "SBans_ConCommand_UnMute", "<#userid|name>", LEVEL_MODERATOR );
	ConCommand::Create( "sbans_unsilence", "SBans_ConCommand_UnSilence", "<#userid|name>", LEVEL_MODERATOR );

	ConCommand::Create( "sbans_help", "SBans_ConCommand_Help", "Show our sourcebans++ commands", LEVEL_MODERATOR );
}

//------------------------------------------------------------------------------------------------------------------------//

CTerrorPlayer @GrabTargetPlayer( CTerrorPlayer@ pAdmin, string target )
{
	CTerrorPlayer@ pTarget = GetPlayerByName( target, false );

	// Not found? Check for SteamID
	if ( pTarget is null )
		@pTarget = GetPlayerBySteamID( target );

	int admin = 0;
	if ( pAdmin !is null )
		admin = pAdmin.entindex();

	if ( pTarget is null )
	{
		string strResult = "SB_TargetNotFound_Reason_3";

		if ( Utils.StrContains( "!", target ) )
			strResult = "SB_TargetNotFound_Reason_1";
		else if ( Utils.StrContains( "#", target ) )
			strResult = "SB_TargetNotFound_Reason_2";

		SBans_SendTextToConsole(
			pAdmin,
			Translate::GrabTranslationFormat( GetLanguage(), "SB_TargetNotFound", { target } )
			+ Translate::GrabTranslation( GetLanguage(), strResult )
		);
		return null;
	}

	if ( pTarget.entindex() == admin )
	{
		SBans_SendTextToConsole( pAdmin, Translate::GrabTranslation( GetLanguage(), "SB_TargetSelf" ) );
		return null;
	}

	if ( AdminSystem.AdminExist( pTarget ) )
	{
		SBans_SendTextToConsole( pAdmin, Translate::GrabTranslation( GetLanguage(), "SB_TargetAdmin" ) );
		return null;
	}

	return pTarget;
}

//------------------------------------------------------------------------------------------------------------------------//

// Via dedicated we start at value 1?
int SBans_GrabArgument( int admin, int arg )
{
	//if ( admin == 0 )
	//	return arg + 1;
	return arg;
}

//------------------------------------------------------------------------------------------------------------------------//

void SBans_ConCommand_Ban( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	int admin = 0;
	if ( pPlayer !is null )
		admin = pPlayer.entindex();

	if ( pArgs.Args() < SBans_GrabArgument( admin, 3 ) )
	{
		string strValue = "sbans_ban";
		SBans_SendTextToConsole( pPlayer, strValue + " " + ConCommand::Help( strValue ) );
		return;
	}

	// Our target
	string arg1 = pArgs.Arg( SBans_GrabArgument( admin, 1 ) );
	string arg2 = pArgs.Arg( SBans_GrabArgument( admin, 2 ) );
	string arg3 = pArgs.Arg( SBans_GrabArgument( admin, 3 ) );

	if ( Utils.StrEql( arg3, "" ) )
		arg3 = "No reason was given.";

	CTerrorPlayer@ pTarget = GrabTargetPlayer( pPlayer, arg1 );
	if ( pTarget is null )
		return;

	NetData nData;
	nData.Write( admin );
	nData.Write( pTarget.entindex() );
	nData.Write( Utils.StringToInt( arg2 ) );
	nData.Write( arg3 );
	Network::CallFunction( "SBans_CreateBan", nData );
}

//------------------------------------------------------------------------------------------------------------------------//

void SBans_ConCommand_Kick( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	int admin = 0;
	if ( pPlayer !is null )
		admin = pPlayer.entindex();

	if ( pArgs.Args() < SBans_GrabArgument( admin, 2 ) )
	{
		string strValue = "sbans_kick";
		SBans_SendTextToConsole( pPlayer, strValue + " " + ConCommand::Help( strValue ) );
		return;
	}

	// Our target
	string arg1 = pArgs.Arg( SBans_GrabArgument( admin, 1 ) );
	string arg2 = pArgs.Arg( SBans_GrabArgument( admin, 2 ) );

	if ( Utils.StrEql( arg2, "" ) )
		arg2 = "No reason was given.";

	CTerrorPlayer@ pTarget = GrabTargetPlayer( pPlayer, arg1 );
	if ( pTarget is null ) return;

	///===========================================================
	// Print Message
	string strType = "{cyan}" + Translate::GrabTranslation( GetLanguage(), "SB_Kicked" );
	string strResult = Translate::GrabTranslationFormat( GetLanguage(), "SB_Formated_MsgShort", { Utils.EscapeCharacters( pTarget.GetPlayerName() ), strType } );
	strResult += "{default}\n" + Translate::GrabTranslationFormat( GetLanguage(), "SB_Formated_Msg_Reason", { arg2 } );

	// Kick the player before we print the msg
	AdminSystem.Kick( pTarget, strResult );

	SBans_SendTextAll( strResult );
	// END Print Message
	///===========================================================

	// Log the stuff
	Log.ToLocation( "sourcebans", LOGTYPE_INFO, "CreateKick: " + strResult );
}

//------------------------------------------------------------------------------------------------------------------------//

void SBans_ConCommand_Gag( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	int admin = 0;
	if ( pPlayer !is null )
		admin = pPlayer.entindex();

	if ( pArgs.Args() < SBans_GrabArgument( admin, 3 ) )
	{
		string strValue = "sbans_gag";
		SBans_SendTextToConsole( pPlayer, strValue + " " + ConCommand::Help( strValue ) );
		return;
	}

	// Our target
	string arg1 = pArgs.Arg( SBans_GrabArgument( admin, 1 ) );
	string arg2 = pArgs.Arg( SBans_GrabArgument( admin, 2 ) );
	string arg3 = pArgs.Arg( SBans_GrabArgument( admin, 3 ) );

	if ( Utils.StrEql( arg3, "" ) )
		arg3 = "No reason was given.";

	CTerrorPlayer@ pTarget = GrabTargetPlayer( pPlayer, arg1 );
	if ( pTarget is null ) return;

	SBans_DoCommBan( admin, pTarget.entindex(), 1, Utils.StringToInt( arg2 ), arg3 );
}

//------------------------------------------------------------------------------------------------------------------------//

void SBans_ConCommand_UnGag( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	int admin = 0;
	if ( pPlayer !is null )
		admin = pPlayer.entindex();

	if ( pArgs.Args() < SBans_GrabArgument( admin, 2 ) )
	{
		string strValue = "sbans_ungag";
		SBans_SendTextToConsole( pPlayer, strValue + " " + ConCommand::Help( strValue ) );
		return;
	}

	// Our target
	string arg1 = pArgs.Arg( SBans_GrabArgument( admin, 1 ) );

	CTerrorPlayer@ pTarget = GrabTargetPlayer( pPlayer, arg1 );
	if ( pTarget is null ) return;

	SBans_DoCommUnBan( admin, pTarget.entindex(), 1 );
}

//------------------------------------------------------------------------------------------------------------------------//

void SBans_ConCommand_Mute( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	int admin = 0;
	if ( pPlayer !is null )
		admin = pPlayer.entindex();

	if ( pArgs.Args() < SBans_GrabArgument( admin, 3 ) )
	{
		string strValue = "sbans_mute";
		SBans_SendTextToConsole( pPlayer, strValue + " " + ConCommand::Help( strValue ) );
		return;
	}

	// Our target
	string arg1 = pArgs.Arg( SBans_GrabArgument( admin, 1 ) );
	string arg2 = pArgs.Arg( SBans_GrabArgument( admin, 2 ) );
	string arg3 = pArgs.Arg( SBans_GrabArgument( admin, 3 ) );

	if ( Utils.StrEql( arg3, "" ) )
		arg3 = "No reason was given.";

	CTerrorPlayer@ pTarget = GrabTargetPlayer( pPlayer, arg1 );
	if ( pTarget is null ) return;

	SBans_DoCommBan( admin, pTarget.entindex(), 2, Utils.StringToInt( arg2 ), arg3 );
}

//------------------------------------------------------------------------------------------------------------------------//

void SBans_ConCommand_UnMute( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	int admin = 0;
	if ( pPlayer !is null )
		admin = pPlayer.entindex();

	if ( pArgs.Args() < SBans_GrabArgument( admin, 2 ) )
	{
		string strValue = "sbans_unmute";
		SBans_SendTextToConsole( pPlayer, strValue + " " + ConCommand::Help( strValue ) );
		return;
	}

	// Our target
	string arg1 = pArgs.Arg( SBans_GrabArgument( admin, 1 ) );

	CTerrorPlayer@ pTarget = GrabTargetPlayer( pPlayer, arg1 );
	if ( pTarget is null ) return;

	SBans_DoCommUnBan( admin, pTarget.entindex(), 2 );
}

//------------------------------------------------------------------------------------------------------------------------//

void SBans_ConCommand_Silence( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	int admin = 0;
	if ( pPlayer !is null )
		admin = pPlayer.entindex();

	if ( pArgs.Args() < SBans_GrabArgument( admin, 3 ) )
	{
		string strValue = "sbans_silence";
		SBans_SendTextToConsole( pPlayer, strValue + " " + ConCommand::Help( strValue ) );
		return;
	}

	// Our target
	string arg1 = pArgs.Arg( SBans_GrabArgument( admin, 1 ) );
	string arg2 = pArgs.Arg( SBans_GrabArgument( admin, 2 ) );
	string arg3 = pArgs.Arg( SBans_GrabArgument( admin, 3 ) );

	if ( Utils.StrEql( arg3, "" ) )
		arg3 = "No reason was given.";

	CTerrorPlayer@ pTarget = GrabTargetPlayer( pPlayer, arg1 );
	if ( pTarget is null ) return;

	SBans_DoCommBan( admin, pTarget.entindex(), 0, Utils.StringToInt( arg2 ), arg3 );
}

//------------------------------------------------------------------------------------------------------------------------//

void SBans_ConCommand_UnSilence( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	int admin = 0;
	if ( pPlayer !is null )
		admin = pPlayer.entindex();

	if ( pArgs.Args() < SBans_GrabArgument( admin, 2 ) )
	{
		string strValue = "sbans_unsilence";
		SBans_SendTextToConsole( pPlayer, strValue + " " + ConCommand::Help( strValue ) );
		return;
	}

	// Our target
	string arg1 = pArgs.Arg( SBans_GrabArgument( admin, 1 ) );

	CTerrorPlayer@ pTarget = GrabTargetPlayer( pPlayer, arg1 );
	if ( pTarget is null ) return;

	SBans_DoCommUnBan( admin, pTarget.entindex(), 0 );
}

//------------------------------------------------------------------------------------------------------------------------//

void SBans_DoCommUnBan( int adminent, int targetent, int value )
{
	NetData nData;
	nData.Write( adminent );
	nData.Write( value );
	nData.Write( targetent );
	Network::CallFunction( "SBans_CreateCommUnBan", nData );
}

//------------------------------------------------------------------------------------------------------------------------//

void SBans_DoCommBan( int adminent, int targetent, int value, int time, string reason )
{
	NetData nData;
	nData.Write( adminent );
	nData.Write( value );
	nData.Write( targetent );
	nData.Write( time );
	nData.Write( reason );
	Network::CallFunction( "SBans_CreateCommBan", nData );
}

//------------------------------------------------------------------------------------------------------------------------//

void SBans_ConCommand_Help( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	PrintConsoleHelpMessage( pPlayer, "======================================" );
	DisplayHelp( pPlayer, "sbans_ban" );
	DisplayHelp( pPlayer, "sbans_kick" );
	DisplayHelp( pPlayer, "sbans_gag" );
	DisplayHelp( pPlayer, "sbans_ungag" );
	DisplayHelp( pPlayer, "sbans_mute" );
	DisplayHelp( pPlayer, "sbans_unmute" );
	DisplayHelp( pPlayer, "sbans_silence" );
	DisplayHelp( pPlayer, "sbans_unsilence" );
	PrintConsoleHelpMessage( pPlayer, "======================================\n" );
}

//------------------------------------------------------------------------------------------------------------------------//

void PrintConsoleHelpMessage( CTerrorPlayer@ pPlayer, string strMsg )
{
	if ( pPlayer is null )
		Chat.PrintToConsole( strMsg );
	else
	{
		CBasePlayer@ pPlayerEnt = pPlayer.opCast();		// Convert to CBasePlayer
		Chat.PrintToConsolePlayer( pPlayerEnt, strMsg );
	}
}

//------------------------------------------------------------------------------------------------------------------------//

void DisplayHelp( CTerrorPlayer@ pPlayer, string convar )
{
	if ( pPlayer is null )
	{
		PrintHelpMsg( null, convar, ConCommand::Help( convar ) );
		return;
	}
	CBasePlayer@ pPlayerEnt = pPlayer.opCast();
	PrintHelpMsg( pPlayerEnt, convar, ConCommand::Help( convar ) );
}

//------------------------------------------------------------------------------------------------------------------------//

void PrintHelpMsg( CBasePlayer@ pPlayer, string convar, string help )
{
	if ( pPlayer is null )
		Chat.PrintToConsole( "\t{cyan}" + convar + "{default} " + help );
	else
		Chat.PrintToConsolePlayer( pPlayer, "\t{cyan}" + convar + "{default} " + help );
}