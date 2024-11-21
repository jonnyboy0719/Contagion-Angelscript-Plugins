namespace GunGame
{
	CASConVar@ pHealthOnKill = null;
	CASConVar@ pHealthAmount = null;
	CASConVar@ pAllowGlow = null;
	
	namespace Cvars
	{
		void Init()
		{
			@GunGame::pHealthOnKill = ConVar::Create( "gg_healthkill", "1", "Players gets health when they kill another player.", true, 0, true, 1 );
			@GunGame::pHealthAmount = ConVar::Create( "gg_healthkill_amount", "25", "The amount of health that will be given to the player.", true, 15, true, 100 );
			@GunGame::pAllowGlow = ConVar::Create( "gg_leader_show", "1", "Should we show show the leader is?", true, 0, true, 1 );
		}
		void OnUnload()
		{
			ConVar::Remove( GunGame::pHealthOnKill );
			ConVar::Remove( GunGame::pHealthAmount );
			ConVar::Remove( GunGame::pAllowGlow );
		}
		bool AllowGlow() { return GunGame::pAllowGlow.GetBool(); }
		bool HealthOnKill() { return GunGame::pHealthOnKill.GetBool(); }
		int HealthAmount() { return GunGame::pHealthAmount.GetInt(); }
	}
}