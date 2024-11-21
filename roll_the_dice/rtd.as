//------------------------------------------------------------------------------------------------------------------------//
// Core
#include "rtd/core.as"
#include "rtd/perks.as"
CASConVar@ pRTD_AutoBots = null;

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
		throw( "The RTD plugin requires \"adminmenu\" to be fully loaded!" );
		return;
	}

	PluginData::SetVersion( "1.1" );
	PluginData::SetAuthor( "JonnyBoy0719" );
	PluginData::SetName( "Roll The Dice" );

	ConCommand::Create( "rtd_roll", ConCmd_RTD, "Roll the dice", LEVEL_NONE );
	ConCommand::Create( "rtd_perks", ConCmd_ShowPerks, "Show the Perks", LEVEL_NONE );
	ConCommand::Create( "rtd_forceroll", ConCmd_ForceRTD, "Force someone to roll the dice", LEVEL_MODERATOR );
	@pRTD_AutoBots = ConVar::Create( "rtd_forcebots", "1", "Causes bots to force RTD at random times.", true, 0, true, 1 );

	ConCommand::RegisterToChat( "rtd_roll", "rtd" );
	ConCommand::RegisterToChat( "rtd_perks", "perks" );
	ConCommand::RegisterToChat( "rtd_forceroll", "forcertd" );

	// Register types
	RTD::RegisterPerks();
	RTD::Menu::OnInit();

	// Hooks
	Events::Player::OnPlayerDisconnected.Hook( @OnPlayerDisconnected );
	Events::Player::OnPlayerKilledPost.Hook( @OnPlayerKilledPost );
	Events::Player::OnPlayerDamagedPre.Hook( @OnPlayerDamagedPre );
	Events::Infected::OnInfectedDamagedPre.Hook( @OnInfectedDamagedPre );
}

//------------------------------------------------------------------------------------------------------------------------//

void OnPluginUnload()
{
	ConCommand::Remove( "rtd_roll" );
	ConCommand::Remove( "rtd_perks" );
	ConCommand::Remove( "rtd_forceroll" );
	ConVar::Remove( pRTD_AutoBots );
	EntityCreator::UnregisterCustomEntity( "turtle_heaven", "RTD::CPerkTurtleHeavenEnt" );
	RTD::Menu::OnUnload();
}

//------------------------------------------------------------------------------------------------------------------------//

void ThePresident_OnMapStart()
{
	g_rtd.Clear();
}

//------------------------------------------------------------------------------------------------------------------------//

void OnProcessRound()
{
	g_rtd.Think();
}

//------------------------------------------------------------------------------------------------------------------------//

void OnFireGameEvent( ASGameEvent &in event, bool &in bClientsided )
{
	g_rtd.OnFireGameEvent( event );
}

//------------------------------------------------------------------------------------------------------------------------//

void ConCmd_RTD( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	g_rtd.ExecuteRandomPerk( pPlayer );
}

//------------------------------------------------------------------------------------------------------------------------//

void ConCmd_ShowPerks( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	RTD::Menu::Draw( pPlayer );
}

//------------------------------------------------------------------------------------------------------------------------//
// Arguments:
// 0 - as_forcertd
// 1 - <player>
// 2 - <perk>
// 3 - <perk_time_override>
void ConCmd_ForceRTD( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	g_rtd.ExecutePerk( pPlayer, GetPlayerByName( pArgs.Arg(1), false ), pArgs.Arg(2), parseFloat( pArgs.Arg(3) ) );
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerDisconnected( CTerrorPlayer@ pPlayer )
{
	g_rtd.EndPerk( pPlayer, k_eDisconnected );
	return HOOK_HANDLED;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerKilledPost( CTerrorPlayer@ pPlayer )
{
	g_rtd.EndPerk( pPlayer, k_eKilled );
	return HOOK_HANDLED;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerDamagedPre(CTerrorPlayer@ pPlayer, CTakeDamageInfo &in DamageInfo)
{
	return g_rtd.OnPlayerDamagedPre(pPlayer, DamageInfo);
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnInfectedDamagedPre(Infected@ pInfected, CTakeDamageInfo &in DamageInfo)
{
	return g_rtd.OnInfectedDamagedPre(pInfected, DamageInfo);
}

//------------------------------------------------------------------------------------------------------------------------//
// 3rd party RTD perks support

void RTD_RegisterItem( IRollTheDiceTypeBase @module )
{
	if ( module is null ) return;
	g_rtd.RegisterItem( module );
}

//------------------------------------------------------------------------------------------------------------------------//
// 3rd party RTD perks support

void RTD_RemoveItem( string module_id )
{
	g_rtd.RemoveItem( module_id );
}
