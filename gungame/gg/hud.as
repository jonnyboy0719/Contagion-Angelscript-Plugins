namespace GunGame
{
    void DrawHudInfo( CTerrorPlayer @pPlayer, const string &in szText, float &in yPos, int &in iID )
    {
        const float m_flDrawTime = 0.25f;
        DrawASUI UIData;
        UIData.ID = iID;
        UIData.Type = UI_Text;
        UIData.DrawType = UI_Top;
        UIData.HalfContentSize = false;
        UIData.Content = szText;
        UIData.DrawTime = m_flDrawTime;
        UIData.Pos = Vector2D( 35, yPos );
        UIData.Size = Vector2D( 0, 0 );
        UIData.ColorContent = Color( 184, 10, 14, 255 );
        pPlayer.UIDraw( UIData );
    }

    //------------------------------------------------------------------------------------------------------------------------//

    void DrawHUDInfo( CTerrorPlayer@ pPlayer, CGunGamePlayer@ data )
    {
        if ( pPlayer is null ) return;
        if ( data is null ) return;
        int g_iWeeklyBonusEXP = 0;
        bool g_AuraIsActive   = false;
        const float yPosIncrease = 15.5f;
        
        float yPos = 130;
        int iID = 0;
        
        string output = "";
        output        = "Level:  " + data.CurrentLevel() + " / " + GunGame::Guns::GetMaxWeaponLevels();
        DrawHudInfo( pPlayer, output, yPos, iID );
        yPos += yPosIncrease; iID++;
        
        output = "Kills:  " + data.kills + " / " + GunGame::Guns::GetNeededKills( data.PlayerIndex );
        DrawHudInfo( pPlayer, output, yPos, iID );
        yPos += yPosIncrease; iID++;
        
        output = "Your SteamID:  " + Utils.Steam64ToSteam32( pPlayer.GetSteamID64() );
        DrawHudInfo( pPlayer, output, yPos, iID );
    }
}