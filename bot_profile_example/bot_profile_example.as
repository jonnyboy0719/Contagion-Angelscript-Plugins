// Bot profile test
void BotProfileTest( const int &in id )
{
	Log.PrintToServerConsole( LOGTYPE_DEBUG, "BotProfileTest(" + id + ")" );

	// Grab our bot profile to the current heap.
	// This object will get erased once we reach the end of this function.
	ASBotProfile @bot = GetBotProfile( id );

	// Stop if we got no profile
	if ( bot is null )
	{
		Log.PrintToServerConsole( LOGTYPE_DEBUG, "The profile [" + id + "] does not exist." );
		return;
	}

	// Print our bot profile to the console:
	Log.PrintToServerConsole( LOGTYPE_DEBUG, "Bot Name: " + bot.GetName() );
	Log.PrintToServerConsole( LOGTYPE_DEBUG, "Bot Aggression: " + bot.GetAggression() );
	Log.PrintToServerConsole( LOGTYPE_DEBUG, "Bot Skill: " + bot.GetSkill() );
	Log.PrintToServerConsole( LOGTYPE_DEBUG, "Bot Teamwork: " + bot.GetTeamwork() );
	Log.PrintToServerConsole( LOGTYPE_DEBUG, "Bot ReactionTime: " + bot.GetReactionTime() );
	Log.PrintToServerConsole( LOGTYPE_DEBUG, "Bot VoiceBank: " + bot.GetVoiceBank() );
	Log.PrintToServerConsole( LOGTYPE_DEBUG, "Bot AttackDelay: " + bot.GetAttackDelay() );
	Log.PrintToServerConsole( LOGTYPE_DEBUG, "Bot Character: " + bot.GetCharacter() );
	Log.PrintToServerConsole( LOGTYPE_DEBUG, "Bot Cost: " + bot.GetCost() );

	// If we got any weapon preferences
	if ( bot.GetWeaponPreferenceCount() > 0 )
	{
		Log.PrintToServerConsole( LOGTYPE_DEBUG, "Bot WeaponPreference: " + bot.GetWeaponPreference( 0 ) );
		Log.PrintToServerConsole( LOGTYPE_DEBUG, "Bot WeaponPreferenceAsString: " + bot.GetWeaponPreferenceAsString( 0 ) );
	}

	Log.PrintToServerConsole( LOGTYPE_DEBUG, "Bot PrefersSilencer: " + bot.PrefersSilencer() );
	Log.PrintToServerConsole( LOGTYPE_DEBUG, "Bot HasPrimaryPreference: " + bot.HasPrimaryPreference() );
	Log.PrintToServerConsole( LOGTYPE_DEBUG, "Bot HasPistolPreference: " + bot.HasPistolPreference() );
	Log.PrintToServerConsole( LOGTYPE_DEBUG, "Bot IsDifficulty( Easy ): " + bot.IsDifficulty( BOT_EASY ) );
	Log.PrintToServerConsole( LOGTYPE_DEBUG, "Bot IsValidForTeam( Survivor Team ): " + bot.IsValidForTeam( TEAM_SURVIVOR ) );
}