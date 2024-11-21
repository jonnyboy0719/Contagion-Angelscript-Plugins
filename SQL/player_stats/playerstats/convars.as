CASConVar@ g_pMaxRankTopCount = null;
CASConVar@ g_pShowRankOnConnect = null;
CASConVar@ g_pAnnounceOnConnect = null;

void RegisterConvars()
{
    @g_pMaxRankTopCount = ConVar::Create( "pstats_max_top_players", "10", "The max top N players to display", true, 10, true, 50 );
    @g_pShowRankOnConnect = ConVar::Create( "pstats_show_rank_onjoin", "1", "If set, player rank will be displayed to the user on every map change", true, 0, true, 1 );
    @g_pAnnounceOnConnect = ConVar::Create( "pstats_cannounce_enabled", "1", "If set, connect announce will be displayed to chat when a player joins", true, 0, true, 1 );
}

void UnRegisterConvars()
{
    ConVar::Remove( g_pMaxRankTopCount );
    ConVar::Remove( g_pShowRankOnConnect );
    ConVar::Remove( g_pAnnounceOnConnect );
}