
void OnPluginInit()
{
	PluginData::SetName( "TEST NETWORK" );
	Events::Player::PlayerSay.Hook( @OnPlayerSay );
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerSay( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	string arg1 = pArgs.Arg( 1 );
	if ( Utils.StrEql( arg1, "!net" ) )
	{
		NetData nData;
		Network::CallFunction( "BB2_OnTimeRanOut", nData );
		return HOOK_HANDLED;
	}
	else if ( Utils.StrEql( arg1, "!nat" ) )
	{
		NetData nData;
		nData.Write( "team_set" );
		nData.Write( TEAM_SURVIVOR );
		Network::CallFunction( "BB2_TestNetwork", nData );
		return HOOK_HANDLED;
	}
	else if ( Utils.StrEql( arg1, "!rgb1" ) )
	{
		array<int> collector = Utils.CollectPlayers();
		for ( uint x = 0; x < collector.length(); x++ )
		{
			CTerrorPlayer @pTerror = ToTerrorPlayer( collector[ x ] );
			if ( pTerror is null )
			{
				collector.removeAt( x );
				continue;
			}
			pTerror.SetRenderMode( kRenderTransAdd );
			pTerror.SetRenderColor( Math::RandomInt( 0, 255 ), Math::RandomInt( 0, 255 ), Math::RandomInt( 0, 255 ), 120 );
		}
		Chat.PrintToChat( pPlayer, "RGB ON" );
		return HOOK_HANDLED;
	}
	else if ( Utils.StrEql( arg1, "!rgb2" ) )
	{
		array<int> collector = Utils.CollectPlayers();
		for ( uint x = 0; x < collector.length(); x++ )
		{
			CTerrorPlayer @pTerror = ToTerrorPlayer( collector[ x ] );
			if ( pTerror is null )
			{
				collector.removeAt( x );
				continue;
			}
			pTerror.SetRenderFX( kRenderFxNone );
			pTerror.SetRenderMode( kRenderNormal );
			pTerror.SetRenderColor( 255, 255, 255, 255 );
		}
		Chat.PrintToChat( pPlayer, "RGB OFF" );
		return HOOK_HANDLED;
	}
	else if ( Utils.StrEql( arg1, "!glow" ) )
	{
		pPlayer.SetRenderFX( kRenderFxGlowShell );
		pPlayer.SetGlow( true, Color( 0, Math::RandomInt( 0, 255 ), Math::RandomInt( 0, 255 ), Math::RandomInt( 0, 255 ) ), 0.1f );
		Chat.PrintToChat( pPlayer, "Glowing." );
		return HOOK_HANDLED;
	}
	else if ( Utils.StrEql( arg1, "!allglow" ) )
	{
		array<int> collector = Utils.CollectPlayers();
		// Go trough the list, and remove any that isn't a valid player, and isn't on TEAM_SURVIVOR
		for ( uint x = 0; x < collector.length(); x++ )
		{
			CTerrorPlayer @pTerror = ToTerrorPlayer( collector[ x ] );
			if ( pTerror is null )
			{
				collector.removeAt( x );
				continue;
			}
			pTerror.SetRenderFX( kRenderFxGlowShell );
			pTerror.SetGlow( true, Color( Math::RandomInt( 0, 255 ), Math::RandomInt( 0, 255 ), Math::RandomInt( 0, 255 ), 255 ), 0.1f );
		}
		Chat.PrintToChat( all, "All Glowing." );
		return HOOK_HANDLED;
	}
	return HOOK_CONTINUE;
}
