CASConVar@ pScreamPartyEnabled = null;
CASConVar@ pScreamPartyAngryDelay = null;

void OnPluginInit()
{
	@pScreamPartyEnabled = ConVar::Create( "as_screamer_party", "1", "Replaces all zombies with screamers!", true, 0, true, 2 );
	@pScreamPartyAngryDelay = ConVar::Create( "as_screamer_party_delay", "1.5", "Replaces all zombies with screamers!", true, 1.0, true, 10.0 );

	PluginData::SetVersion( "1.0" );
	PluginData::SetAuthor( "JonnyBoy0719" );
	PluginData::SetName( "Screamer Party" );

	Events::Infected::OnInfectedSpawned.Hook( @OnInfectedSpawned );
	Events::Infected::OverrideZombieSpawn.Hook( @OverrideZombieSpawn );
}

void OnPluginUnload()
{
	ConVar::Remove( pScreamPartyEnabled );
	ConVar::Remove( pScreamPartyAngryDelay );
}

HookReturnCode OverrideZombieSpawn( string &in szZombieEnt, string &out szZombieEntOverride )
{
	if ( !pScreamPartyEnabled.GetBool() ) return HOOK_CONTINUE;
	// Only replace normal zombies
	if ( szZombieEnt != "zombie" ) return HOOK_CONTINUE;
	// Randomize if we should be a bride or not.
	bool bIsBride = ( Math::RandomInt( 0, 1 ) == 1 ) ? true : false;
	szZombieEntOverride = bIsBride ? "screamerbride" : "screamer";
	return HOOK_HANDLED;
}

HookReturnCode OnInfectedSpawned( Infected@ pInfected )
{
	if ( !pScreamPartyEnabled.GetBool() ) return HOOK_CONTINUE;
	if ( pInfected is null ) return HOOK_CONTINUE;
	// Very angy :)
	if ( pScreamPartyEnabled.GetInt() == 2 )
	{
		CBaseEntity@ pBaseEnt = pInfected.opCast();
		Engine.Ent_Fire_Ent( pBaseEnt, "BecomeFurious", "", formatFloat( pScreamPartyAngryDelay.GetFloat() ) );
	}
	return HOOK_HANDLED;
}
