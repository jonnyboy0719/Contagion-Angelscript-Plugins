CASConVar@ pExplosiveZomb = null;

void OnPluginInit()
{
	ConCommand::Create( "as_explosive_zombies_force", "ConCommand_ZombieGoBoom", "Causes zombies to forcefully explode.", LEVEL_ADMIN );
	@pExplosiveZomb = ConVar::Create( "as_explosive_zombies", "1", "Causes zombies to explode on death.", true, 0, true, 1 );

	PluginData::SetVersion( "1.0" );
	PluginData::SetAuthor( "JonnyBoy0719" );
	PluginData::SetName( "Exploding Zombies" );

	Events::Infected::OnInfectedKilled.Hook(@InfectedGoesBoom);
}

void OnPluginUnload()
{
	// Remove our convar and concommand
	ConCommand::Remove( "as_explosive_zombies_force" );
	ConVar::Remove( pExplosiveZomb );	// or as_explosive_zombies
}

void ConCommand_ZombieGoBoom( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
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
		CauseExplosion( pInfected, false );
	}
}

void CauseExplosion( Infected@ pInfected, bool bIgnoreZombie )
{
	if ( pInfected is null ) return;
	CBaseEntity@ pInfectedBase = pInfected.opCast();
	// Cause an explosion where our zombie is at
	if ( bIgnoreZombie )
		Utils.EnvExplosion( pInfectedBase, 600, 80, "ValveBiped.Bip01_Pelvis" );
	else
		Utils.EnvExplosion( pInfectedBase.GetAbsOrigin() + Vector( 0, 0, 5 ), 600, 80 );
}

HookReturnCode InfectedGoesBoom(Infected@ pInfected, CTakeDamageInfo &in DamageInfo)
{
	if ( pExplosiveZomb.GetBool() )
		CauseExplosion( pInfected, true );
	return HOOK_CONTINUE;
}