bool HasButtonFlag( const int &in flags, const int &in flag )
{
	return ((flags & flag) == flag);
}

void OnProcessRound()
{
	for( int y = 1; y <= Globals.GetMaxClients(); y++ )
	{
		CTerrorPlayer@ pPlayer = ToTerrorPlayer( y );
		if ( pPlayer is null ) continue;
		int nButtonPressed = pPlayer.m_afButtonPressed;
		int nButtonReleased = pPlayer.m_afButtonReleased;
		int nButtonLast = pPlayer.m_afButtonLast;
		// We just pressed it.
		if ( HasButtonFlag( nButtonPressed, IN_ATTACK2 ) )
		{
			Chat.PrintToChat( all, "{limegreen}player has flag {gold}IN_ATTACK2" );
		}
		// When we release our button
		if ( HasButtonFlag( nButtonReleased, IN_ATTACK2 ) )
		{
			Chat.PrintToChat( all, "{limegreen}player has released flag {gold}IN_ATTACK2" );
		}
		// This function saves the previous pressed input, and will spam. If it spams, then it works.
		if ( HasButtonFlag( nButtonLast, IN_ATTACK2 ) )
		{
			Chat.PrintToChat( all, "{limegreen}player last flag was {gold}IN_ATTACK2" );
		}
	}
}