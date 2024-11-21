//------------------------------------------------------------------------------------------------------------------------//
// Deathmatch core
#include "dm/core.as"

//------------------------------------------------------------------------------------------------------------------------//
// Interface
#include "admin/shared/interface.as"

//------------------------------------------------------------------------------------------------------------------------//
// Import
import void AdminMenu_RegisterItem( IAdminMenuItemBase @module ) from "adminmenu.as";
import void AdminMenu_RemoveItem( string module_id ) from "adminmenu.as";
import void AdminMenu_BackToGroup( CTerrorPlayer@ pPlayer, int group ) from "adminmenu.as";

//------------------------------------------------------------------------------------------------------------------------//

void OnPluginInit()
{
	// Make sure adminmenu is loaded
	if ( !PluginData::IsLoaded( "adminmenu" ) )
	{
		throw( "The Deatmatch plugin requires \"adminmenu\" to be fully loaded!" );
		return;
	}

	PluginData::SetVersion( "1.0" );
	PluginData::SetAuthor( "JonnyBoy0719" );
	PluginData::SetName( "Deathmatch" );

	EntRemovals();
	HuntedDMSetup();
	SetSomeGameRules();

	DeathMatch::Init();
}

//------------------------------------------------------------------------------------------------------------------------//

void OnMapInit()
{
	EntRemovals();
}

//------------------------------------------------------------------------------------------------------------------------//

void PurgeItems( const string &in strClassname )
{
	CBaseEntity @pEnt = FindEntityByClassname( null, strClassname );
	while( pEnt !is null )
	{
		// Remove it
		pEnt.SUB_Remove();
		// Find new entity
		@pEnt = FindEntityByClassname( pEnt, strClassname );
	}
}

//------------------------------------------------------------------------------------------------------------------------//

void EntRemovals()
{
	PurgeItems( "item_ammo*" );
	PurgeItems( "weapon_*" );
}

//------------------------------------------------------------------------------------------------------------------------//

void OnEntityDropped( CTerrorPlayer@ pPlayer, CBaseEntity@ pEntity )
{
	if ( pEntity is null ) return;
	if ( Utils.StrContains( "item_ammo", pEntity.GetClassname() ) )
		pEntity.SUB_Remove();
	else
		pEntity.SUB_StartFadeOut( 10.0f, false );
}

//------------------------------------------------------------------------------------------------------------------------//

void ThePresident_OnRoundStart()
{
	HuntedDMSetup();
}

//------------------------------------------------------------------------------------------------------------------------//

void HuntedDMSetup()
{
	ThePresident::Hunted::SetDeathmatch( true );
	ThePresident::Hunted::SetRandomizeWeapons( true );
	Engine.RunConsoleCommand( "mp_roundlimit 1" );
}

//------------------------------------------------------------------------------------------------------------------------//

void ThePresident_OnMapStart()
{
	ThePresident_OnRoundStart();
}

//------------------------------------------------------------------------------------------------------------------------//

void OnProcessRound()
{
	DeathMatch::Think();
}

//------------------------------------------------------------------------------------------------------------------------//

void OnPluginUnload()
{
	Engine.EnableCustomSettings( false );
	DeathMatch::Unload();
}

//------------------------------------------------------------------------------------------------------------------------//

void SetSomeGameRules()
{
	Engine.EnableCustomSettings( true );
	ThePresident.OverrideWeaponFastSwitch( true );

	// Find our console variable and put it inside our reference variable
	CASConVarRef@ infinite_collected_ammo = ConVar::Find( "sv_infinite_collected_ammo" );
	if ( infinite_collected_ammo is null ) return;
	// We don't need to remove the cheat value, as the reference convar will talk directly with the actual console variable
	infinite_collected_ammo.SetValue( "1" );
}