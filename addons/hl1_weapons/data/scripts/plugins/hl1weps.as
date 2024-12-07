#include "hl1/core.as"

void OnPluginInit()
{
	PluginData::SetVersion( "1.0" );
	PluginData::SetAuthor( "JonnyBoy0719" );
	PluginData::SetName( "HL1 Weapons" );

	RegisterAllWeapons();
}

void OnPluginUnload()
{
	HL1WEPS::Unload();
}

void ThePresident_OnMapStart()
{
	RegisterAllWeapons();
}

void RegisterAllWeapons()
{
	HL1WEPS::RegisterWeapons();
	HL1WEPS::RegisterEntities();
}
