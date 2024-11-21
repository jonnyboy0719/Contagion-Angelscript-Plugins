namespace Menu
{
    enum MenuItems
    {
        k_MenuDraw_Rank = 0,
        k_MenuDraw_RankDetail,
        k_MenuDraw_RanksIngame,
        k_MenuDraw_Top10
    }

    //------------------------------------------------------------------------------------------------------------------------//

    class CMenuItem : CAdminMenuItemBase
    {
        CMenuItem()
        {
            m_ID    = "as_playerstats";
            m_Name  = "Player Stats";
            m_Group = GROUP_PLAYER_CMD;
            m_Level = LEVEL_NONE;
        }

        // Do nothing
        void GoBack( CTerrorPlayer @pPlayer ) override {}
        void GoBack( CTerrorPlayer @pPlayer, int client )
        {
            PlayerRank @handle = GrabPlayerRank( client );
            if ( handle is null ) return;
            OnUserStatsRead( pPlayer, 0, handle.rank );
            //RecalculateUserStats( pPlayer, handle.steamid );
        }
        
        uint GetMaxPlayerLength( MenuItems menu_item )
        {
            if ( menu_item == k_MenuDraw_Top10 )
            {
                uint val  = uint(g_pMaxRankTopCount.GetInt());
                uint list = player_ranks.length();
                if ( val > list ) return list;
                return val;
            }
            return player_ranks.length();
        }

        void OnItemOpen( CTerrorPlayer @pPlayer, MenuItems menu_item )
        {
            if ( menu_item == k_MenuDraw_Rank )
            {
                PlayerRank @handle = GrabPlayerRank( pPlayer.GetSteamID64() );
                if ( handle is null ) return;
                OnUserStatsRead( pPlayer, 0, handle.rank );
                //RecalculateUserStats( pPlayer, handle.steamid );
                return;
            }
            OnPageChanged( pPlayer, 0, menu_item );
        }

        int CalculatePageCount( bool bAdd, uint page, MenuItems menu_item )
        {
            int li = 0;
            for ( uint i = page; i < GetMaxPlayerLength( menu_item ); i++ )
            {
                if ( page >= GetMaxPlayerLength( menu_item ) ) break;
                PlayerRank @handle = player_ranks[i];
                if ( handle is null ) continue;
                if ( li > 6 ) break;
                li++;
            }
            if ( bAdd )
                return page + li;
            return page - li;
        }

        void FillRankInfo( Menu &out pMenu, uint page, MenuItems menu_item )
        {
            int li = 0;
            for ( uint i = page; i < GetMaxPlayerLength( menu_item ); i++ )
            {
                if ( page >= GetMaxPlayerLength( menu_item ) ) break;
                PlayerRank @handle = player_ranks[i];
                if ( handle is null ) continue;
                // If in-game check, then only show those who are currently online.
                if ( menu_item == k_MenuDraw_RanksIngame )
                {
                    CTerrorPlayer @pPlayer = GetPlayerBySteamID( handle.steamid );
                    if ( pPlayer is null ) continue;
                }
                if ( li > 6 ) break;
                string szVal = handle.name + " (Rank " + handle.rank + ")";
                if ( li == 5 ) szVal = szVal + "\n";
                if ( !pMenu.AddItem( szVal ) ) break;
                li++;
            }
            // Index 8 is always "Close"
            // Index 9 is always "Next"
            if ( page > 0 )
                pMenu.SetExit( true, "Back" );
            else
                pMenu.SetExit( true, "Close" );
            if ( li > 6 )
                pMenu.SetNext( true );
        }

        string GetSlotName( MenuItems menu_item )
        {
            string slot_name = "Something went wrong!";
            switch( menu_item )
            {
                case k_MenuDraw_Rank: slot_name = "Player Stats"; break;
                case k_MenuDraw_RankDetail: slot_name = "Detailed Player Stats"; break;
                case k_MenuDraw_Top10: slot_name = "Top " + g_pMaxRankTopCount.GetInt() + " Players"; break;
                case k_MenuDraw_RanksIngame: slot_name = "Player In-Game Ranks"; break;
            }
            return slot_name;
        }

        void ExecuteArgument( CTerrorPlayer@ pPlayer, uint page, uint result, int client )
        {
            if ( client == 0 )
            {
                PlayerRank @handle = GrabPlayerFromID( result );
                if ( handle is null ) return;
                OnUserStatsRead( pPlayer, 0, handle.rank );
                //RecalculateUserStats( pPlayer, handle.steamid );
            }
            else
                OnUserStatsRead( pPlayer, 1, client );
        }

        void OnPageChanged( CTerrorPlayer @pPlayer, uint page, MenuItems menu_item )
        {
            Menu pMenu;
            FillRankInfo( pMenu, page, menu_item );
            pMenu.SetID( m_ID + ";" + page + ";" + menu_item );
            pMenu.SetTitle( GetSlotName( menu_item ) );
            pMenu.Display( pPlayer, -1 );
        }
        
        // We need a custom one for user stats
        void FillUserStats( CTerrorPlayer@ pPlayer, int page, int client, bool more_stats )
        {
            PlayerRank @handle = GrabPlayerRank( client );
            if ( handle is null ) return;
            
            // Create our menu
            UserMessage.Begin( pPlayer, "CreateMenu" );
                UserMessage.WriteString( m_ID + ";" + page + ";" + k_MenuDraw_Rank + ";" + client );
            UserMessage.End();
            
            // Title
            UserMessage.Begin( pPlayer, "AddItemMenu" );
                UserMessage.WriteString( GetSlotName( (page == 0) ? k_MenuDraw_Rank : k_MenuDraw_RankDetail ) );
            UserMessage.End();
            
            // Spacer
            UserMessage.Begin( pPlayer, "AddItemMenu" );
                UserMessage.WriteString( " " );
            UserMessage.End();
            
            // Our items
            if ( more_stats )
            {
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " Name: \"" + handle.name +"\"" );
                UserMessage.End();
                
                // Spacer
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " " );
                UserMessage.End();
                
                // Survivor Stats
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( "->1. Survivor" );
                UserMessage.End();
                
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " ☼ Escaped (" + handle.escaped + ")" );
                UserMessage.End();
                
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " ☼ Kills (" + handle.infected_killed + ")" );
                UserMessage.End();
                
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " ☼ Headshots (" + handle.infected_headshot + ")" );
                UserMessage.End();
                
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " ☼ Crippled Zombies (" + handle.infected_crippled + ")" );
                UserMessage.End();
                
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " ☼ Melee Kills (" + handle.kills_melee + ")" );
                UserMessage.End();
                
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " ☼ Zombie Doctors (" + handle.kills_doctors + ")" );
                UserMessage.End();
                
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " ☼ Zombie Looters (" + handle.kills_looters + ")" );
                UserMessage.End();
                
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " ☼ Zombie Riots (" + handle.kills_riots + ")" );
                UserMessage.End();
                
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " ☼ Zombie Chargers (" + handle.kills_chargers + ")" );
                UserMessage.End();
                
                // Spacer
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " " );
                UserMessage.End();
                
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( "->8. Back" );
                UserMessage.End();
            }
            else
            {
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " Name: \"" + handle.name +"\"" );
                UserMessage.End();
                
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " Rank: #" + handle.rank );
                UserMessage.End();
                
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " Points: " + handle.points );
                UserMessage.End();
                
                // Spacer
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " " );
                UserMessage.End();
                
                // Survivor Stats
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( "->1. Survivor" );
                UserMessage.End();
                
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " ☼ Kills (" + handle.infected_killed + ")" );
                UserMessage.End();
                
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " ☼ Headshots (" + handle.infected_headshot + ")" );
                UserMessage.End();
                
                // Spacer
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " " );
                UserMessage.End();
                
                // Show more stats
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( "->2. More Stats" );
                UserMessage.End();
                
                // Spacer
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( " " );
                UserMessage.End();
                
                UserMessage.Begin( pPlayer, "AddItemMenu" );
                    UserMessage.WriteString( "->0. Close" );
                UserMessage.End();
            }
            
            // Display the menu
            UserMessage.Begin( pPlayer, "DisplayMenu" );
            UserMessage.End();
        }
        
        void OnUserStatsRead( CTerrorPlayer @pPlayer, int page, int client )
        {
            if ( page == 0 )
                FillUserStats( pPlayer, page, client, false );
            else
                FillUserStats( pPlayer, page, client, true );
        }

        void OnMenuExecuted( CTerrorPlayer@ pPlayer, CASCommand @pArgs, int &in iValue ) override
        {
            string arg0         = pArgs.Arg( 0 );   // MainID
            string arg1         = pArgs.Arg( 1 );   // Page
            string arg2         = pArgs.Arg( 2 );   // Menu Item
            string arg3         = pArgs.Arg( 3 );   // Player Index
            uint page           = parseUInt( arg1 );
            int client          = parseInt( arg3 );
            MenuItems menu_item = MenuItems(parseInt( arg2 ));
            uint result         = iValue - 1; // Reduce 1 for the result
            switch( iValue )
            {
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7:
                {
                    ExecuteArgument( pPlayer, page, result, client );
                }
                break;
                case 8:
                {
                    if ( client > 0 )
                        GoBack( pPlayer, client );
                    else
                    {
                        if ( page > 1 )
                            OnPageChanged( pPlayer, CalculatePageCount( false, page - 6, menu_item ), menu_item );
                        else
                            GoBack( pPlayer );
                    }
                }
                break;
                case 9:
                {
                    if ( client > 0 )
                        OnUserStatsRead( pPlayer, 1, client );
                    else
                        OnPageChanged( pPlayer, CalculatePageCount( true, page + 6, menu_item ), menu_item );
                }
                break;
            }
        }
    }
    CMenuItem @pMenuItem = CMenuItem();

    //------------------------------------------------------------------------------------------------------------------------//

    void OnInit()
    {
        AdminMenu_RegisterItem( pMenuItem );
    }

    //------------------------------------------------------------------------------------------------------------------------//

    void OnUnload()
    {
        AdminMenu_RemoveItem( pMenuItem.GetID() );
    }

    //------------------------------------------------------------------------------------------------------------------------//

    void Draw( CTerrorPlayer @pPlayer, MenuItems menu_item )
    {
        pMenuItem.OnItemOpen( pPlayer, menu_item );
    }
}

//------------------------------------------------------------------------------------------------------------------------//
// Unused. It works, but slow.
/*
void RecalculateUserStats( CTerrorPlayer@ pPlayer, string steamid )
{
    dictionary @dict = {{"player", pPlayer.entindex()}};
    SQL::SendQueryEx(
        gMainConnection,
        "SELECT `last_known_alias`, `steam_id`, `escaped`, `points`, `survivor_killed`, `survivor_infected`, `survivor_grappled`, `infected_killed`, `infected_headshot`, `infected_crippled`, `kills_melee`, `kills_doctors`, `kills_looters`, `kills_riots`, `kills_chargers` FROM stats_players WHERE steam_id = '" + steamid + "'",
        Query_PlayerRankRecalculation, dict
    );
}

//------------------------------------------------------------------------------------------------------------------------//

void Query_PlayerRankRecalculation( IMySQL@ pQuery, dictionary @dict )
{
    if ( pQuery is null ) return;
    if ( pQuery.Failed() ) return;
    PlayerRank @handle = GrabPlayerRank( SQL::ReadResult::GetString( pQuery, "steam_id" ) );
    if ( handle !is null )
        handle.AddFromQuery( pQuery );
        
    CTerrorPlayer @pPlayer = ToTerrorPlayer( int( dict['player'] ) );
    if ( pPlayer is null ) return;
    Menu::pMenuItem.OnUserStatsRead( pPlayer, 0, handle.rank );
}
*/