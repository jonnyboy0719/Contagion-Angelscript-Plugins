void RegisterHooks()
{
	Events::Player::OnPlayerConnected.Hook( @SBans_PlayerConnected );
	Events::Player::OnPlayerInitSpawn.Hook( @SBans_OnPlayerInitSpawn );	// Called when we spawned for the first time
	Events::Player::OnPlayerSpawn.Hook( @SBans_OnPlayerSpawn );

	Events::Admin::OnUserBannedEx.Hook( @SBans_OnUserBannedEx );
	Events::Admin::OnUserBannedSteamID.Hook( @SBans_OnUserBannedSteamID );
	Events::Admin::OnUserGagMute.Hook( @SBans_OnUserGagMute );
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode SBans_PlayerConnected( CTerrorPlayer@ pPlayer )
{
	// Ban check doesn't check for msg print check, only mute/gag does
	NetData nData;
	nData.Write( pPlayer.entindex() );
	nData.Write( 1 );
	Network::CallFunction( "SBans_CheckBanStatus", nData );
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode SBans_OnPlayerInitSpawn( CTerrorPlayer@ pPlayer )
{
	NetData nData;
	nData.Write( pPlayer.entindex() );
	nData.Write( 0 );
	nData.Write( 1 );
	Network::CallFunction( "SBans_CheckBanStatus", nData );
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode SBans_OnPlayerSpawn( CTerrorPlayer@ pPlayer )
{
	// Set this to false, since we are going to check it again.
	// Since we may have ungagged or unmuted this player via the SBans page,
	// or that the time expired.
	AdminSystem.Mute( pPlayer, 1, false, "" );
	AdminSystem.Gag( pPlayer, 1, false, "" );

	NetData nData;
	nData.Write( pPlayer.entindex() );
	nData.Write( 0 );
	nData.Write( 0 );	// We don't want to see any messages being printed
	Network::CallFunction( "SBans_CheckBanStatus", nData );
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode SBans_OnUserBannedEx( CTerrorPlayer@ pPlayer, CTerrorPlayer@ pAdmin, int &in iMinutes, const string &in strReason )
{
	int admin = 0;
	if ( pAdmin !is null )
		admin = pAdmin.entindex();
	NetData nData;
	nData.Write( admin );
	nData.Write( pPlayer.entindex() );
	nData.Write( iMinutes );
	nData.Write( strReason );
	Network::CallFunction( "SBans_CreateBan", nData );
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode SBans_OnUserBannedSteamID( int &in uid, CTerrorPlayer@ pAdmin, int &in iMinutes, const string &in strReason )
{
	int admin = 0;
	if ( pAdmin !is null )
		admin = pAdmin.entindex();

	// Find our player
	string strSteamID = Utils.Steam64ToSteam32( formatInt( uid ) );
	CTerrorPlayer@ pPlayer = GetPlayerBySteamID( strSteamID );
	if ( pPlayer is null )
	{
		// Manual SteamID ban.
		NetData nData;
		nData.Write( admin );
		nData.Write( strSteamID );
		nData.Write( iMinutes );
		nData.Write( strReason );
		Network::CallFunction( "SBans_CreateIDBan", nData );
		return HOOK_CONTINUE;
	}

	NetData nData;
	nData.Write( admin );
	nData.Write( pPlayer.entindex() );
	nData.Write( iMinutes );
	nData.Write( strReason );
	Network::CallFunction( "SBans_CreateBan", nData );
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode SBans_OnUserGagMute( bool &in bMuted, CTerrorPlayer@ pPlayer, CTerrorPlayer@ pAdmin, int &in iMinutes, const string &in strReason )
{
	int admin = 0;
	if ( pAdmin !is null )
		admin = pAdmin.entindex();
	SBans_DoCommBan( admin, pPlayer.entindex(), bMuted ? 2 : 1, iMinutes, strReason );
	return HOOK_CONTINUE;
}
