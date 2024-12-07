// Entities
#include "ents/hl1_explode.as"
#include "ents/hl1_tripmine.as"
#include "ents/hl1_glauncher.as"
#include "ents/hl1_satchel.as"

// Weapon base
#include "weapon_base.as"

// Weapons
#include "weapon_tripmine.as"
#include "weapon_glock.as"
#include "weapon_python.as"
#include "weapon_mp5.as"
#include "weapon_crowbar.as"
#include "weapon_satchel.as"
#include "weapon_shotgun.as"

namespace HL1WEPS
{
	void RegisterWeapons()
	{
		EntityCreator::RegisterCustomEntity( k_eCustomWeapon, "weapon_hl_tripmine", "CScriptHLWeaponTripmine" );
		EntityCreator::RegisterCustomEntity( k_eCustomWeapon, "weapon_hl_glock", "CScriptHLWeaponGlock" );
		EntityCreator::RegisterCustomEntity( k_eCustomWeapon, "weapon_hl_357", "CScriptHLWeaponPython" );
		EntityCreator::RegisterCustomEntity( k_eCustomWeapon, "weapon_hl_mp5", "CScriptHLWeaponMP5" );
		EntityCreator::RegisterCustomEntity( k_eCustomWeapon, "weapon_hl_shotgun", "CScriptHLWeaponShotgun" );
		EntityCreator::RegisterCustomEntity( k_eCustomWeapon, "weapon_hl_crowbar", "CScriptHLWeaponCrowbar" );
		EntityCreator::RegisterCustomEntity( k_eCustomWeapon, "weapon_hl_satchel", "CScriptHLWeaponSatchel" );
	}

	void RegisterEntities()
	{
		EntityCreator::RegisterCustomEntity( k_eCustomEntity, "hl1_satchel", "CScriptSatchelThrownNPC" );
		EntityCreator::RegisterCustomEntity( k_eCustomEntity, "hl1_tripmine", "CScriptTripMineNPC" );
		EntityCreator::RegisterCustomEntity( k_eCustomEntity, "hl1_glauncher", "CScriptGrenadeLaunchedNPC" );
		EntityCreator::RegisterCustomEntity( k_eCustomEntity, "hl1_classic_explode", "CHL1ClassicExplode" );

		// Precache after we did the entities
		Precache();
	}

	void Precache()
	{
		Engine.PrecacheFile( soundbank, "auto/hl1_weapons.txt" );
		Engine.PrecacheFile( soundbank, "hl1_weapons.bnk" );

		Engine.PrecacheFile( hud, "weapon_hl_crowbar.txt" );
		Engine.PrecacheFile( hud, "weapon_hl_glock.txt" );
		Engine.PrecacheFile( hud, "weapon_hl_357.txt" );
		Engine.PrecacheFile( hud, "weapon_hl_mp5.txt" );
		Engine.PrecacheFile( hud, "weapon_hl_shotgun.txt" );
		Engine.PrecacheFile( hud, "weapon_hl_satchel.txt" );
		Engine.PrecacheFile( hud, "weapon_hl_tripmine.txt" );
		Engine.PrecacheFile( hud, "scripts/weapon_hl_crowbar.txt" ); 
		Engine.PrecacheFile( hud, "scripts/weapon_hl_glock.txt" ); 
		Engine.PrecacheFile( hud, "scripts/weapon_hl_357.txt" ); 
		Engine.PrecacheFile( hud, "scripts/weapon_hl_mp5.txt" ); 
		Engine.PrecacheFile( hud, "scripts/weapon_hl_shotgun5.txt" ); 
		Engine.PrecacheFile( hud, "scripts/weapon_hl_tripmine.txt" ); 
		Engine.PrecacheFile( hud, "scripts/weapon_hl_satchel.txt" ); 

		Engine.PrecacheFile( model, "models/hl1/weapons/v_crowbar.mdl" );
		Engine.PrecacheFile( model, "models/hl1/weapons/w_crowbar.mdl" );
		Engine.PrecacheFile( model, "models/hl1/weapons/v_glock.mdl" );
		Engine.PrecacheFile( model, "models/hl1/weapons/w_glock.mdl" );
		Engine.PrecacheFile( model, "models/hl1/weapons/v_mp5.mdl" );
		Engine.PrecacheFile( model, "models/hl1/weapons/w_mp5.mdl" );
		Engine.PrecacheFile( model, "models/hl1/weapons/v_shotgun.mdl" );
		Engine.PrecacheFile( model, "models/hl1/weapons/w_shotgun.mdl" );
		Engine.PrecacheFile( model, "models/hl1/weapons/v_357.mdl" );
		Engine.PrecacheFile( model, "models/hl1/weapons/w_357.mdl" );
		Engine.PrecacheFile( model, "models/hl1/weapons/v_tripmine.mdl" );
		Engine.PrecacheFile( model, "models/hl1/weapons/w_tripmine.mdl" );
		Engine.PrecacheFile( model, "models/hl1/weapons/v_satchel.mdl" );
		Engine.PrecacheFile( model, "models/hl1/weapons/w_satchel.mdl" );

		Engine.PrecacheFile( model, "models/hl1/weapons/glauncher.mdl" );
		Engine.PrecacheFile( model, "models/hl1/weapons/w_satchel_thrown.mdl" );

		Engine.PrecacheFile( material, "sprites/fexplo" );
		Engine.PrecacheFile( material, "sprites/gexplo" );

		Engine.PrecacheFile( material, "sprites/hl1/640hud7" );
		Engine.PrecacheFile( material, "sprites/hl1/crosshairs" );
		Engine.PrecacheFile( material, "sprites/hl1/tripmine" );
		Engine.PrecacheFile( material, "sprites/hl1/tripmine_sb" );
		Engine.PrecacheFile( material, "sprites/hl1/killfeed/tripmine" );

		Engine.PrecacheFile( material, "models/hl1/weapons/crowbar/chrome" );
		Engine.PrecacheFile( material, "models/hl1/weapons/crowbar/chrome_red" );
		Engine.PrecacheFile( material, "models/hl1/weapons/crowbar" );

		Engine.PrecacheFile( material, "models/hl1/weapons/glock/back" );
		Engine.PrecacheFile( material, "models/hl1/weapons/glock/gclip" );
		Engine.PrecacheFile( material, "models/hl1/weapons/glock/gclipinside" );
		Engine.PrecacheFile( material, "models/hl1/weapons/glock/side" );
		Engine.PrecacheFile( material, "models/hl1/weapons/glock/top" );
		Engine.PrecacheFile( material, "models/hl1/weapons/glock/glockback" );
		Engine.PrecacheFile( material, "models/hl1/weapons/glock/glockfront" );
		Engine.PrecacheFile( material, "models/hl1/weapons/glock/glockside" );
		Engine.PrecacheFile( material, "models/hl1/weapons/glock/glocktop1" );

		Engine.PrecacheFile( material, "models/hl1/weapons/python/pythoncylrear2" );
		Engine.PrecacheFile( material, "models/hl1/weapons/python/Pythonhandle" );

		Engine.PrecacheFile( material, "models/hl1/weapons/mp5/buttstockrear" );
		Engine.PrecacheFile( material, "models/hl1/weapons/mp5/clip" );
		Engine.PrecacheFile( material, "models/hl1/weapons/mp5/glback" );
		Engine.PrecacheFile( material, "models/hl1/weapons/mp5/gunbodyrear" );
		Engine.PrecacheFile( material, "models/hl1/weapons/mp5/gunsidemap" );
		Engine.PrecacheFile( material, "models/hl1/weapons/mp5/handleback" );
		Engine.PrecacheFile( material, "models/hl1/weapons/mp5/HK_chrome" );
		Engine.PrecacheFile( material, "models/hl1/weapons/mp5/sighttop" );
		Engine.PrecacheFile( material, "models/hl1/weapons/mp5/Silencerback" );
		Engine.PrecacheFile( material, "models/hl1/weapons/mp5/M203" );
		Engine.PrecacheFile( material, "models/hl1/weapons/mp5/MP5sideview" );

		Engine.PrecacheFile( material, "models/hl1/weapons/bulletCHROME" );
		Engine.PrecacheFile( material, "models/hl1/weapons/chrome" );
		Engine.PrecacheFile( material, "models/hl1/weapons/lensCHROME" );
		Engine.PrecacheFile( material, "models/hl1/weapons/tripmine_reference" );

		Engine.PrecacheFile( material, "models/hl1/weapons/grenade/Side1" );
		Engine.PrecacheFile( material, "models/hl1/weapons/grenade/Tip1" );

		Engine.PrecacheFile( material, "models/hl1/weapons/satchel/view/det_front" );
		Engine.PrecacheFile( material, "models/hl1/weapons/satchel/view/det_side" );
		Engine.PrecacheFile( material, "models/hl1/weapons/satchel/view/dettop" );
		Engine.PrecacheFile( material, "models/hl1/weapons/satchel/view/detbutn_bright" );
		Engine.PrecacheFile( material, "models/hl1/weapons/satchel/view/satchel_body" );
		Engine.PrecacheFile( material, "models/hl1/weapons/satchel/view/radioside" );
		Engine.PrecacheFile( material, "models/hl1/weapons/satchel/view/strap" );
		Engine.PrecacheFile( material, "models/hl1/weapons/satchel/view/expl" );
		Engine.PrecacheFile( material, "models/hl1/weapons/satchel/view/flapchrome" );
		Engine.PrecacheFile( material, "models/hl1/weapons/satchel/black" );
		Engine.PrecacheFile( material, "models/hl1/weapons/satchel/radioside" );
		Engine.PrecacheFile( material, "models/hl1/weapons/satchel/tag" );
		Engine.PrecacheFile( material, "models/hl1/weapons/satchel/wrldsatchel" );
		Engine.PrecacheFile( material, "models/hl1/weapons/buckleCHROME" );
		Engine.PrecacheFile( material, "models/hl1/weapons/rubbergloveCHROME" );
	}

	void Unload()
	{
		EntityCreator::UnregisterCustomEntity( "weapon_hl_tripmine", "CScriptHLWeaponTripmine" );
		EntityCreator::UnregisterCustomEntity( "weapon_hl_glock", "CScriptHLWeaponGlock" );
		EntityCreator::UnregisterCustomEntity( "weapon_hl_357", "CScriptHLWeaponPython" );
		EntityCreator::UnregisterCustomEntity( "weapon_hl_mp5", "CScriptHLWeaponMP5" );
		EntityCreator::UnregisterCustomEntity( "weapon_hl_shotgun", "CScriptHLWeaponShotgun" );
		EntityCreator::UnregisterCustomEntity( "weapon_hl_crowbar", "CScriptHLWeaponCrowbar" );
		EntityCreator::UnregisterCustomEntity( "weapon_hl_satchel", "CScriptHLWeaponSatchel" );

		EntityCreator::UnregisterCustomEntity( "hl1_satchel", "CScriptSatchelThrownNPC" );
		EntityCreator::UnregisterCustomEntity( "hl1_tripmine", "CScriptTripMineNPC" );
		EntityCreator::UnregisterCustomEntity( "hl1_glauncher", "CScriptGrenadeLaunchedNPC" );
		EntityCreator::UnregisterCustomEntity( "hl1_classic_explode", "CHL1ClassicExplode" );
	}
}