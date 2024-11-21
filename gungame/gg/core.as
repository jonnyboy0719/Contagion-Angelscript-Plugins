namespace GunGame
{
    int iWinner = -1;
    CGunGamePlayer @pLeader = null;
    void RemoveGlow( CGunGamePlayer @pPlayer )
    {
        if ( pPlayer is null ) return;
        CTerrorPlayer@ pTerrorOldLeader = ToTerrorPlayer( pPlayer.PlayerIndex );
        if ( pTerrorOldLeader is null ) return;
        //pTerrorOldLeader.SetOutline( -1, off );
        //for ( uint i = 0; i < arrChristmasProps.length(); i++ )
        //  Utils.CosmeticRemove( pTerrorOldLeader, arrChristmasProps[i] );
    }
    void SetGlow( CGunGamePlayer @pPlayer )
    {
        if ( !GunGame::Cvars::AllowGlow() ) return;
        if ( pPlayer is null ) return;
        CTerrorPlayer@ pTerrorNewLeader = ToTerrorPlayer( pPlayer.PlayerIndex );
        if ( pTerrorNewLeader is null ) return;
        //pTerrorNewLeader.SetOutline( -1, on, occlude, Color(245, 66, 66) );
        //Utils.CosmeticWear( pTerrorNewLeader, arrChristmasProps[Math::RandomInt( 0, arrChristmasProps.length()-1 )] );
    }
    void SetGlowIfLeader( int playerindex )
    {
        if ( pLeader is null ) return;
        if ( pLeader.PlayerIndex != playerindex ) return;
        SetGlow( pLeader );
    }
    void ResetLeader()
    {
        RemoveGlow( pLeader );
        @pLeader = null;
    }
    void CheckWinner()
    {
        if ( iWinner == -1 ) return;
        CTerrorPlayer@ pTerrorPlayer = ToTerrorPlayer( iWinner );
        Chat.PrintToChat( all, "{azure}" + pTerrorPlayer.GetPlayerName() + " {arcana}has won!" );
        ThePresident.ForceWinState( STATE_WIN );
        iWinner = -1;
    }
    void SetWinner( int player ) { iWinner = player; }
    bool CheckForNewLeader( CGunGamePlayer @pPlayer )
    {
        if ( pLeader is null )
        {
            SetGlow( pPlayer );
            @pLeader = pPlayer;
            CTerrorPlayer@ pTerrorNewLeader = ToTerrorPlayer( pPlayer.PlayerIndex );
            Chat.PrintToChat( all, "{green}" + pTerrorNewLeader.GetPlayerName() + " is now the new leader!" );
            return false;
        }
        if ( pPlayer.PlayerIndex == pLeader.PlayerIndex ) return false;
        if ( pLeader.level >= pPlayer.level ) return false;
        CTerrorPlayer@ pTerrorOldLeader = ToTerrorPlayer( pLeader.PlayerIndex );
        CTerrorPlayer@ pTerrorNewLeader = ToTerrorPlayer( pPlayer.PlayerIndex );
        Chat.PrintToChat( all, "{red}" + pTerrorOldLeader.GetPlayerName() + " lost the lead!\n{green}" + pTerrorNewLeader.GetPlayerName() + " is now the new leader!" );
        RemoveGlow( pLeader );
        SetGlow( pPlayer );
        @pLeader = pPlayer;
        return true;
    }
    CGunGamePlayer @GetLeader() { return pLeader; }
}

// BB2 announcer support
void BB2_OnTimeRanOut( NetObject@ pData )
{
    CGunGamePlayer @pLeader = GunGame::GetLeader();
    CTerrorPlayer @pWinner = ToTerrorPlayer( pLeader.PlayerIndex );
    if ( pWinner is null )
        Chat.PrintToChat( all, "{arcana}Nobody was in the lead. It's a {gold}Draw{arcana}!" );
    else
    {
        Chat.PrintToChat( all, "{azure}" + pWinner.GetPlayerName() + " {arcana}has won!" );
        GunGame::iWinner = -1;
        ThePresident.ForceWinState( STATE_WIN );
    }
    ThePresident.ForceWinState( STATE_WIN );
}
