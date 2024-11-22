CASConVar@ pRiotPartyEnabled = null;

void OnPluginInit()
{
	@pRiotPartyEnabled = ConVar::Create( "as_riot_party", "1", "Replaces all zombies with riot officers!", true, 0, true, 2 );

	PluginData::SetVersion( "1.0" );
	PluginData::SetAuthor( "JonnyBoy0719" );
	PluginData::SetName( "Riot Party" );

	Events::Infected::OverrideZombieSpawn.Hook( @OverrideZombieSpawn );
}

void OnPluginUnload()
{
	ConVar::Remove( pRiotPartyEnabled );
}

HookReturnCode OverrideZombieSpawn( string &in szZombieEnt, string &out szZombieEntOverride )
{
	if ( !pRiotPartyEnabled.GetBool() ) return HOOK_CONTINUE;
	// Only replace normal zombies
	if ( szZombieEnt != "zombie" ) return HOOK_CONTINUE;
	szZombieEntOverride = "zombieriot";
	return HOOK_HANDLED;
}
