namespace GunGame
{
	namespace Music
	{
		void LevelUp(CTerrorPlayer@ pTerrorPlayer)
		{
			// Player leveled up
			pTerrorPlayer.PlayWwiseSound( "SFX_ELEVATOR_DING_01", "", 150 );
		}
		void LevelDown(CTerrorPlayer@ pTerrorPlayer)
		{
			// Player lost a level, what a shame
			pTerrorPlayer.PlayWwiseSound( "SFX_ACTION_CHAINLINK", "", 150 );
		}
	}
}