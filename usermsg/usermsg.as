void OnPluginInit()
{
	Events::Player::PlayerSay.Hook( @PlayerSay );
}

HookReturnCode PlayerSay( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	string arg1 = pArgs.Arg( 1 );
	if ( Utils.StrEql( arg1, "!event" ) || Utils.StrEql( arg1, "/event" ) )
	{
		UserMessage.Begin( null, "Crescendo" );
		UserMessage.End();
		return HOOK_HANDLED;
	}
	return HOOK_CONTINUE;
}
