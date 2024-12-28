void OnPluginInit()
{
	PluginData::SetName( "Become A Bunny (BHOP)" );
	// New hook event from v2.3.0.0.9
	Events::Player::OnPlayerRunCommand.Hook( @OnPlayerRunCommand );
	// Make sure we got infinite stamina
	SetInfiniteValues( true );
}

//------------------------------------------------------------------------------------------------------------------------//

void OnPluginUnload()
{
	// Reset the value
	SetInfiniteValues( false );
}

//------------------------------------------------------------------------------------------------------------------------//

void SetInfiniteValues( bool bEnable )
{
	CASConVarRef@ infinite_collected_ammo = ConVar::Find( "sv_infinite_stamina" );
	if ( infinite_collected_ammo is null ) return;
	infinite_collected_ammo.SetValue( bEnable ? "1" : "0" );
}

//------------------------------------------------------------------------------------------------------------------------//

bool HasButtonFlag( const int &in flags, const int &in flag )
{
	return ((flags & flag) == flag);
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerRunCommand( CTerrorPlayer@ pPlayer, int &out nButtons )
{
	// If we are jumping
	if ( HasButtonFlag( nButtons, IN_JUMP ) )
	{
		// Check if we are not the ground
		if ( !pPlayer.IsGrounded() )
		{
			// Do the jumping (if not on a ladder)
			if ( pPlayer.GetMoveType() != MOVETYPE_LADDER )
				nButtons &= ~IN_JUMP;
		}
		return HOOK_HANDLED;
	}
	return HOOK_CONTINUE;
}
