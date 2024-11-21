#include "base/respawn.as"
#include "base/gunmenu.as"
#include "base/score_manager.as"
#include "shared.as"
#include "hooks.as"

namespace DeathMatch
{
	void Init()
	{
		Respawn::OnInit();
		GunMenu::OnInit();
		Hooks::Init();
		Cvars::Init();
	}

	void Think()
	{
		DeathMatch::Respawn::OnThink();
	}

	void Unload()
	{
		GunMenu::OnUnload();
		Cvars::OnUnload();
	}
}

CTerrorPlayer @GetPlayerWithMaxScore()
{
	// Just grab a random survivor from our collection.
	array<int> collector = Utils.CollectPlayers();
	int iPlayerIndex = -1;
	int iScoreAmount = 0;
	// Go trough the list, and remove any that isn't a valid player, and isn't on TEAM_SURVIVOR
	for ( uint x = 0; x < collector.length(); x++ )
	{
		CTerrorPlayer @pPlayer = ToTerrorPlayer( collector[ x ] );
		if ( pPlayer is null )
		{
			collector.removeAt( x );
			continue;
		}
		if ( pPlayer.GetScore() <= iScoreAmount ) continue;
		iPlayerIndex = pPlayer.entindex();
		iScoreAmount = pPlayer.GetScore();
	}
	if ( iPlayerIndex == -1 ) return null;
	return ToTerrorPlayer( iPlayerIndex );
}

// BB2 announcer support
void BB2_OnTimeRanOut( NetObject@ pData )
{
	CTerrorPlayer @pWinner = GetPlayerWithMaxScore();
	if ( pWinner is null )
	{
		Chat.PrintToChat( all, "{arcana}Nobody scored enough points. It's a {gold}Draw{arcana}!" );
		ThePresident.ForceWinState( STATE_WIN );
	}
	DeathMatch::ScoreManager::PrintVictory( pWinner );
	ThePresident.ForceWinState( STATE_WIN );
}
