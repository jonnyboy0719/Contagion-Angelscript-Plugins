namespace DeathMatch
{
	// Our survivor team ID
	const int TEAM_SURVIVORS = 2;
	// Weapon Slot ID
	const int WEP_SLOT_PRIMARY = 1;
	const int WEP_SLOT_SECONDARY = 2;
	const int WEP_SLOT_SPECIAL = 3;

	// Convars
	namespace Cvars
	{
		CASConVar@ GunMenuOnSpawn = null;
		CASConVar@ GetScoreTotal = null;
		CASConVar@ GetProtectionTime = null;

		void Init()
		{
			@GunMenuOnSpawn = ConVar::Create( "as_dm_gunmenu_spawn", "1", "Show the gunmenu on spawn?", true, 0, true, 1 );
			@GetScoreTotal = ConVar::Create( "as_dm_scoreamount", "1000", "How much score does a player need until they win?", true, 0, false, 0 );
			@GetProtectionTime = ConVar::Create( "as_dm_spawnprotection", "3.0", "How long should we protect our player?", true, 0.3, true, 5 );
		}

		void OnUnload()
		{
			ConVar::Remove( GunMenuOnSpawn );
			ConVar::Remove( GetScoreTotal );
			ConVar::Remove( GetProtectionTime );
		}
	}
}