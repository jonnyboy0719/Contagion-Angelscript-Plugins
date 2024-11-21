#include "guns_base.as"
namespace GunGame
{
	namespace Guns
	{
		void Setup()
		{
			gg_weapons = {
				CGunGameWeapon( "ak74", 2 ),
				CGunGameWeapon( "ar15", 2 ),
				CGunGameWeapon( "scar", 2 ),
				CGunGameWeapon( "acr", 2 ),
				CGunGameWeapon( "blr", 2 ),
				CGunGameWeapon( "m1garand", 2 ),
				CGunGameWeapon( "sniper", 2 ),
				CGunGameWeapon( "doublebarrel", 2 ),
				CGunGameWeapon( "autoshotgun", 2 ),
				CGunGameWeapon( "mossberg", 2 ),
				CGunGameWeapon( "remington870", 2 ),
				CGunGameWeapon( "overunder", 2 ),
				CGunGameWeapon( "compbow", 2 ),
				CGunGameWeapon( "crossbow", 2 ),
				CGunGameWeapon( "grenade", 2 ),
				CGunGameWeapon( "grenadelauncher", 2 ),
				CGunGameWeapon( "flamethrower", 2 ),
				CGunGameWeapon( "mp5k", 2 ),
				CGunGameWeapon( "kg9", 2 ),
				CGunGameWeapon( "mac10", 2 ),
				CGunGameWeapon( "handcannon", 2 ),
				CGunGameWeapon( "revolver", 2 ),
				CGunGameWeapon( "revolver_black", 2 ),
				CGunGameWeapon( "357", 2 ),
				CGunGameWeapon( "sig", 2 ),
				CGunGameWeapon( "1911", 2 ),
				CGunGameWeapon( "fingergun", 2 ),
				CGunGameWeapon( "crowbar_green", 1 )
			};
		}
		
		int GetMaxWeaponLevels() { return gg_weapons.length(); }
		
		bool GiveNextWeapon( int player_level, int player_kills )
		{
			// Grab current weapon from our level, and check its needed amount of kills.
			CGunGameWeapon@ pGGWeapon = gg_weapons[player_level];
			if ( pGGWeapon is null ) return false;
			return pGGWeapon.GiveNewWeapon( player_kills );
		}
		
		bool IsWinner( int player_level )
		{
			if ( player_level >= GetMaxWeaponLevels() ) return true;
			return false;
		}
		
		string GetWeapon( int player_level )
		{
			CGunGameWeapon@ pGGWeapon = gg_weapons[player_level];
			if ( pGGWeapon is null ) return "";
			return pGGWeapon.GetWeapon();
		}
		
		int GetNeededKills( int player_level )
		{
			CGunGameWeapon@ pGGWeapon = gg_weapons[player_level];
			if ( pGGWeapon is null ) return 0;
			return pGGWeapon.kills;
		}
	}
}