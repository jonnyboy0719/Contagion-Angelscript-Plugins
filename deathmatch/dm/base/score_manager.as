namespace DeathMatch
{
	namespace ScoreManager
	{
		void CheckKiller( CTerrorPlayer@ pAttacker )
		{
			int max_score = DeathMatch::Cvars::GetScoreTotal.GetInt();
			if ( max_score <= 0 ) return;
			if ( pAttacker.GetScore() < max_score ) return;
			PrintVictory( pAttacker );
			ThePresident.ForceWinState( STATE_WIN );
		}

		void PrintVictory( CTerrorPlayer@ pWinner )
		{
			if ( pWinner is null ) return;
			// Player win!
			// The victory goes to %name% with the score of %score%!
			Chat.PrintToChat( all, "{arcana}The victory goes to {azure}" + pWinner.GetPlayerName() + "{arcana} with the score of {gold}" + pWinner.GetScore() + "{arcana}!" );
		}
	}
}