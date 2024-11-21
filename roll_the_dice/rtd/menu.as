namespace RTD
{
	namespace Menu
	{
		class CMenuItem : CAdminMenuItemBase
		{
			CMenuItem()
			{
				m_ID = "as_rtdperks";
				m_Name = "Available RTD Perks";
				m_Group = GROUP_NO_MENU_CMD;
				m_Level = LEVEL_NONE;
			}

			// We use SetExit, so let's just close it.
			void GoBack( CTerrorPlayer @pPlayer ) override { }

			void OnItemOpen( CTerrorPlayer @pPlayer ) override
			{
				OnPageChanged( pPlayer, 0 );
			}

			void OnPageChanged( CTerrorPlayer @pPlayer, uint page )
			{
				Menu pMenu;
				FillItems( pMenu, page );
				pMenu.SetID( m_ID + ";" + page );
				pMenu.SetTitle( "RTD Effects:" );
				pMenu.Display( pPlayer, -1 );
			}

			void FillItems( Menu &out pMenu, uint page )
			{
				int li = 0;
				for ( uint i = page; i < g_rtd.length(); i++ )
				{
					if ( page >= g_rtd.length() ) break;
					IRollTheDiceTypeBase @pItem = g_rtd.GetItemFromResult( i );
					if ( pItem is null ) continue;
					string itemname = pItem.GetName();
					if ( li > 6 ) break;
					if ( li == 5 ) itemname = itemname + "\n";
					if ( !pMenu.AddItem( itemname ) ) break;
					li++;
				}
				// Index 8 is always "Back" (or close)
				if ( page > 0 )
					pMenu.SetBack( true );
				else
					pMenu.SetExit( true, "Close" );
				// Index 9 is always "Next"
				if ( li > 6 )
					pMenu.SetNext( true );
			}

			void ExecuteArgument( CTerrorPlayer@ pPlayer, uint result, uint page )
			{
				IRollTheDiceTypeBase @pItem = g_rtd.GetItemFromResult( result );
				if ( pItem is null ) return;
				string item = pItem.GetName();
				if ( Utils.StrEql( item, "" ) ) return;
				// DEBUG
				//CBasePlayer@ pBasePlayer = pPlayer.opCast();
				//Chat.PrintToChat( pBasePlayer, "{gold}[{green}AS{gold}]{white} Reading Item {green}" + item + "{white}..." );
				string type = "Effect: ";
				switch( pItem.GetPerkType() )
				{
					case k_eUnknown: type += "Unknown"; break;
					case k_eBad: type += "Bad"; break;
					case k_eNeutral: type += "Neutral"; break;
					case k_eGood: type += "Good"; break;
				}
				// Show our item, but make sure it reads the page + 7
				// that way it will read the same page as before.
				uint pager = page + 7;
				Menu pMenu;
				pMenu.SetBack( true );
				pMenu.SetID( m_ID + ";" + pager );
				pMenu.SetTitle( item + "\n" + type + "\n" + pItem.GetDesc() + "\n" );
				pMenu.Display( pPlayer, -1 );
			}

			void OnMenuExecuted( CTerrorPlayer@ pPlayer, CASCommand @pArgs, int &in iValue ) override
			{
				string arg0 = pArgs.Arg( 0 );	// MainID
				string arg1 = pArgs.Arg( 1 );	// Page
				uint page = parseUInt( arg1 );
				uint result = page + iValue - 1; // Reduce 1 for the result
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
						ExecuteArgument( pPlayer, result, page );
					}
					break;
					case 8:
					{
						if ( page > 0 )
							OnPageChanged( pPlayer, page - 7 );
						else
							GoBack( pPlayer );
					}
					break;
					case 9:
					{
						OnPageChanged( pPlayer, page + 7 );
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

		void Draw( CTerrorPlayer @pPlayer )
		{
			pMenuItem.OnItemOpen( pPlayer );
		}
	}
}