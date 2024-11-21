HookReturnCode OnPlayerSay( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
    string arg1 = pArgs.Arg( 1 );
    if ( Utils.StrEql( arg1, "!rank" ) || Utils.StrEql( arg1, "/rank" ) )
    {
        Menu::Draw( pPlayer, Menu::k_MenuDraw_Rank );
        return (arg1.findFirst("/") != 0) ? HOOK_CONTINUE : HOOK_HANDLED;
    }
    else if ( Utils.StrEql( arg1, "!top" ) || Utils.StrEql( arg1, "/top" ) )
    {
        Menu::Draw( pPlayer, Menu::k_MenuDraw_Top10 );
        return (arg1.findFirst("/") != 0) ? HOOK_CONTINUE : HOOK_HANDLED;
    }
    else if ( Utils.StrEql( arg1, "!ranks" ) || Utils.StrEql( arg1, "/ranks" ) )
    {
        Menu::Draw( pPlayer, Menu::k_MenuDraw_RanksIngame );
        return (arg1.findFirst("/") != 0) ? HOOK_CONTINUE : HOOK_HANDLED;
    }
    return HOOK_CONTINUE;
}