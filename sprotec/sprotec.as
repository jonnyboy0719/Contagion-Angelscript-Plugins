
array<float> _respawn_protection;
CASConVar@ ZombieSafe = null;
CASConVar@ GetProtectionTime = null;

//------------------------------------------------------------------------------------------------------------------------//

void OnPluginInit()
{
	PluginData::SetVersion( "1.0" );
	PluginData::SetAuthor( "JonnyBoy0719" );
	PluginData::SetName( "Spawn Protection" );
	Events::Player::OnPlayerSpawn.Hook( @OnPlayerSpawn );
	Events::Player::OnPlayerConnected.Hook( @OnPlayerConnected );
	_respawn_protection.resize( Globals.GetMaxClients() + 1 );	
	@ZombieSafe = ConVar::Create( "as_spawnprotection_zombiesafe", "1", "Kill the zombies within radius when we spawn?", true, 0, true, 1 );
	@GetProtectionTime = ConVar::Create( "as_spawnprotection_time", "3.0", "How long should we protect our player?", true, 0.3, true, 5 );
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerSpawn( CTerrorPlayer@ pPlayer )
{
	if ( pPlayer is null ) return HOOK_CONTINUE;
	_respawn_protection[pPlayer.entindex()] = Globals.GetCurrentTime() + GetProtectionTime.GetFloat();
	pPlayer.SetRenderFX( kRenderFxDistort );
	pPlayer.SetRenderMode( kRenderTransAdd );
	pPlayer.SetRenderColor( 0, 255, 0, 120 );
	pPlayer.SetGodMode( true );
	Chat.PrintToChat( pPlayer, "{gold}[{green}Spawn Protection{gold}]{white} You will be spawn protected for {lightgreen}" + GetProtectionTime.GetFloat() + "{white} seconds." );
	Schedule::Task( GetProtectionTime.GetFloat(),  pPlayer.entindex(), RemoveProtection );
	if ( ZombieSafe.GetBool() )
		KillZombiesInRadius( pPlayer.GetAbsOrigin(), 320.0f );
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerConnected( CTerrorPlayer@ pPlayer )
{
	if ( pPlayer is null ) return HOOK_CONTINUE;
	_respawn_protection[pPlayer.entindex()] = 0.0f;
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

void KillZombiesInRadius( const Vector &in origin, const float &in radius )
{
	// Collect all zombies
	array<int> collector = Utils.CollectInfected();

	// No zombies found? then skip
	if ( collector.length() == 0 ) return;

	// Go trough our collector, and explode all zombies
	Infected@ pInfected = null;
	for ( uint i = 0; i < collector.length(); i++ )
	{
		@pInfected = ToInfected( collector[ i ] );
		if ( pInfected is null ) continue;
		if ( Globals.Distance( origin, pInfected.GetAbsOrigin() ) > radius ) continue;
		pInfected.SUB_Remove();
	}
}

//------------------------------------------------------------------------------------------------------------------------//

void RemoveProtection( int client )
{
	CTerrorPlayer @pTerror = ToTerrorPlayer( client );
	if ( pTerror is null ) return;
	float flProtection = _respawn_protection[ client ];
	float timeleft = flProtection - Globals.GetCurrentTime();
	if ( timeleft < 0 )
	{
		if ( flProtection != -1 )
		{
			_respawn_protection[ client ] = -1;
			pTerror.SetGodMode( false );
			pTerror.SetRenderFX( kRenderFxNone );
			pTerror.SetRenderMode( kRenderNormal );
			pTerror.SetRenderColor( 255, 255, 255, 255 );
			Chat.PrintToChat( pTerror, "{gold}[{green}Spawn Protection{gold}]{white} You are no longer spawn protected." );
		}
	}
}