
//------------------------------------------------------------------------------------------------------------------------//

void OnPluginInit()
{
	PluginData::SetVersion( "1.0" );
	PluginData::SetAuthor( "JonnyBoy0719" );
	PluginData::SetName( "Custom Model Example" );

	Events::Player::PlayerSay.Hook( @OnPlayerSay );
	Events::Player::OnMenuExecuted.Hook( @OnMenuExecuted );

	PrecacheModels();
}

//------------------------------------------------------------------------------------------------------------------------//

void PrecacheModels()
{
	Engine.PrecacheFile( model, "models/survivors/male/inmate.mdl" );
	Engine.PrecacheFile( model, "models/survivors/male/riot_officer.mdl" );
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnMenuExecuted( CTerrorPlayer@ pPlayer, const string &in szID, int &in iValue )
{
	if ( Utils.StrEql( szID, "custom_model" ) )
	{
		switch( iValue )
		{
			case 1:
			{
				pPlayer.SetModel( "models/survivors/male/riot_officer.mdl" );
				pPlayer.SetArmModel( "models/weapons/v_shared/v_hands_riot.mdl" );
			}
			break;

			case 2:
			{
				pPlayer.SetModel( "models/survivors/male/inmate.mdl" );
				pPlayer.ResetArms();
			}
			break;
		}
	}
	return HOOK_HANDLED;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerSay( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	string arg1 = pArgs.Arg( 1 );
	if ( Utils.StrEql( arg1, "!apple" ) )
	{
		// Create our menu
		Menu pMenu;

		// Set a custom ID for our menu. Default menu ID is "default"
		pMenu.SetID("custom_model");

		// Set a title
		pMenu.SetTitle("Choose new model");

		// Add our items
		pMenu.AddItem("Riot Officer");
		pMenu.AddItem("Inmate");

		// Display to all for 20 seconds
		// Set it to -1 for infinite time
		pMenu.Display(pPlayer, 20);
		return HOOK_HANDLED;
	}
	return HOOK_CONTINUE;
}
