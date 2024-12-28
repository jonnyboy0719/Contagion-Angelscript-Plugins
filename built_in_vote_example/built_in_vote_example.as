void VoteOutput( const string &in szResult, int nYesVotes, int nNoVotes  )
{
	Log.PrintToServerConsole( LOGTYPE_DEBUG, "Vote was a success! Result: [" + szResult + "]" );
	Log.PrintToServerConsole( LOGTYPE_DEBUG, "Yes Votes: [" + nYesVotes + "]" );
	Log.PrintToServerConsole( LOGTYPE_DEBUG, "No Votes: [" + nNoVotes + "]" );
}

void ExampleVote( CTerrorPlayer @pTerror )
{
	ASVoteItem my_vote;

	// The player who started this vote.
	// Can be set to null, or skipped.
	//my_vote.SetPlayer( pTerror );

	// The function that will be fired if the vote was a success
	my_vote.SetFunction( VoteOutput );

	// Our vote detail information.
	// Use %s1 to show the "Details" information.
	my_vote.Name = "Vote YES if you like %s1!";

	// Our item we want to vote for.
	my_vote.Details = "Sexy Waffles";

	// The string we want to display if this vote was a success
	// Use %s1 to show the "Details" information.
	my_vote.PassedString = "You love %s1!";

	// Team restriction, does not apply if we have no Player.
	my_vote.AllyRestriction = true;

	// Start our vote
	Utils.StartVote( my_vote );
}