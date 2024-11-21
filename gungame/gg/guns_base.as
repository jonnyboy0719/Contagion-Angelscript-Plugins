array<CGunGameWeapon@> gg_weapons;

class CGunGameWeapon
{
	string weapon;
	int kills;

	CGunGameWeapon(const string &in szWeapon, int iKills)
	{
		weapon = szWeapon;
		kills = iKills;
	}

	bool GiveNewWeapon(int player_kills)
	{
		if ( player_kills >= kills ) return true;
		return false;
	}
	
	string GetWeapon() { return weapon; }
}