CASConVar@ pConZomb = null;
CASConVar@ pConZombFast = null;

const string s_ErrorZombieModel = "models/zombies/error_man_zombie/error_man_zombie.mdl";

void OnPluginInit()
{
	@pConZomb = ConVar::Create( "as_errorman", "1", "Causes zombies to become errors. Why would you do this?", true, 0, true, 1 );
	@pConZombFast = ConVar::Create( "as_errorman_fast", "0", "Make the error zombies run?", true, 0, true, 1 );

	ConVar::Register( pConZomb, ConVar_ErrorZomb );
	ConVar::Register( pConZombFast, ConVar_FastZomb );

	PluginData::SetVersion( "1.0" );
	PluginData::SetAuthor( "JonnyBoy0719" );
	PluginData::SetName( "ERROR Zombies" );

	Events::Infected::OnInfectedSpawned.Hook( @OnInfectedSpawned_ErrorMan );

	Engine.PrecacheFile( model, s_ErrorZombieModel );
	Engine.AddToDownloadTable( s_ErrorZombieModel );
}

//------------------------------------------------------------------------------------------------------------------------//

void ConVar_ErrorZomb(string &in strNewValue, string &in strOldValue)
{
	int value = parseInt(strNewValue);
	if ( value != 1 ) return;
	array<int> collector = Utils.CollectInfected();
	if ( collector.length() == 0 ) return;
	Infected@ pInfected = null;
	for ( uint i = 0; i < collector.length(); i++ )
	{
		@pInfected = ToInfected( collector[ i ] );
		SetNewModel( pInfected );
	}
}

//------------------------------------------------------------------------------------------------------------------------//

void ConVar_FastZomb(string &in strNewValue, string &in strOldValue)
{
	array<int> collector = Utils.CollectInfected();
	if ( collector.length() == 0 ) return;
	Infected@ pInfected = null;
	for ( uint i = 0; i < collector.length(); i++ )
	{
		@pInfected = ToInfected( collector[ i ] );
		SetNewSpeed( pInfected );
	}
}

//------------------------------------------------------------------------------------------------------------------------//

void ThePresident_OnMapStart()
{
	Engine.PrecacheFile( model, s_ErrorZombieModel );
}

//------------------------------------------------------------------------------------------------------------------------//

void OnPluginUnload()
{
	ConVar::Remove( pConZomb );
	ConVar::Remove( pConZombFast );
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnInfectedSpawned_ErrorMan( Infected@ pInfected )
{
	if ( pInfected !is null )
	{
		SetNewModel( pInfected );
		SetNewSpeed( pInfected );
	}
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

void SetNewModel( Infected@ pInfected )
{
	if ( pInfected is null ) return;
	if ( pConZomb is null ) return;
	if ( !pConZomb.GetBool() ) return;
	// Make the zombie go ERROR, but scary
	pInfected.SetModel( s_ErrorZombieModel );
}

//------------------------------------------------------------------------------------------------------------------------//

void SetNewSpeed( Infected@ pInfected )
{
	if ( pInfected is null ) return;
	if ( pConZombFast is null ) return;
	if ( !pConZombFast.GetBool() ) return;
	// bye bye players!
	pInfected.SetAnimationSet( 10 );
	// Don't forget to make this zombie angry!
	pInfected.Enrage();
}
