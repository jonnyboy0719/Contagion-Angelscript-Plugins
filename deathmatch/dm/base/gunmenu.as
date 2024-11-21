namespace DeathMatch
{
	namespace GunMenu
	{
		array<string> s_availablemods;

		class CWeaponItem
		{
			string weapon;
			string name;
			string mod;
			int slot;
			CWeaponItem(const string &in szWeapon, const string &in szName, const string &in szMod, int iSlot)
			{
				weapon = szWeapon;
				name = szName;
				mod = szMod;
				slot = iSlot;
				if ( !Utils.StrEql( mod, "" ) && !IsModInstalled() )
				{
					if ( PluginData::IsLoaded( mod ) )
						s_availablemods.insertLast( mod );
				}
				// Debug
				//Log.PrintToServerConsole( LOGTYPE_INFO, "CWeaponItem(" + szWeapon + "," + szName + "," + szMod + "," + iSlot + ")" );
			}
			bool IsModInstalled()
			{
				for ( uint i = 0; i < s_availablemods.length(); i++ )
				{
					string szModFind = s_availablemods[i];
					if ( Utils.StrEql( mod, szModFind ) ) return true;
				}
				return false;
			}
			bool IsAvailable( int iSlot )
			{
				if ( slot != iSlot ) return false;
				if ( !Utils.StrEql( mod, "" ) )
					return IsModInstalled();
				return true;
			}
		}

		class CMenuItem : CAdminMenuItemBase
		{
			private array<CWeaponItem@> s_list;

			CMenuItem()
			{
				s_availablemods.resize(0);
				m_ID = "as_gunmenu";
				m_Name = "Gun Menu";
				m_Group = GROUP_NO_MENU_CMD;
				m_Level = LEVEL_NONE;
				PopulateList();
			}

			// Do nothing
			void GoBack( CTerrorPlayer @pPlayer ) override {}

			void PopulateList()
			{
				FileSystem::CreateFolder( "deathmatch" );
				JsonValues@ temp = FileSystem::ReadFile( "deathmatch/gunmenu" );
				if ( temp is null )
				{
					s_list.insertLast( CWeaponItem( "ak74", "AK74", "", WEP_SLOT_PRIMARY ) );
					return;
				}
				array<string> arr;
				temp.GetArray( arr );
				for ( uint i = 0; i < arr.length(); i++ )
				{
					string item = arr[i];
					string weapon_name = FileSystem::GrabString( temp, item, "name" );
					string mod_requirement = FileSystem::GrabString( temp, item, "mod" );
					int weapon_slot = FileSystem::GrabInt( temp, item, "slot" );
					s_list.insertLast( CWeaponItem( item, weapon_name, mod_requirement, weapon_slot ) );
				}
			}

			string GetRandomWeaponFromSlot( int slot )
			{
				array<string> arr;
				for ( uint i = 0; i < s_list.length(); i++ )
				{
					CWeaponItem @item = s_list[i];
					if ( !item.IsAvailable( slot ) ) continue;
					arr.insertLast( item.weapon );
				}
				if ( arr.length() <= 0 ) return "ak74";
				return arr[ Math::RandomInt( 0, arr.length() -1 ) ];
			}

			void OnItemOpen( CTerrorPlayer @pPlayer ) override
			{
				// If bot, then just give random stuff
				if ( pPlayer.IsBot() )
				{
					pPlayer.StripEquipment( true );
					pPlayer.GiveWeapon( GetRandomWeaponFromSlot( WEP_SLOT_PRIMARY ) );
					pPlayer.GiveWeapon( GetRandomWeaponFromSlot( WEP_SLOT_SECONDARY ) );
					//pPlayer.GiveWeapon( GetRandomWeaponFromSlot( WEP_SLOT_SPECIAL ) );
					return;
				}
				OnPageChanged( pPlayer, 0, WEP_SLOT_PRIMARY );
			}

			int CalculatePageCount( bool bAdd, uint page, int slot )
			{
				int li = 0;
				for ( uint i = page; i < s_list.length(); i++ )
				{
					if ( page >= s_list.length() ) break;
					CWeaponItem @item = s_list[i];
					if ( li > 6 ) break;
					if ( !item.IsAvailable( slot ) ) continue;
					li++;
				}
				if ( bAdd )
					return page + li;
				return page - li;
			}

			void FillWeapons( Menu &out pMenu, uint page, int slot )
			{
				int li = 0;
				for ( uint i = page; i < s_list.length(); i++ )
				{
					if ( page >= s_list.length() ) break;
					CWeaponItem @item = s_list[i];
					if ( li > 6 ) break;
					if ( !item.IsAvailable( slot ) ) continue;
					string szVal = item.name;
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

			CWeaponItem @GetFromResult( uint page, uint result, int slot )
			{
				int li = 0;
				for ( uint i = page; i < s_list.length(); i++ )
				{
					if ( page >= s_list.length() ) break;
					CWeaponItem @item = s_list[i];
					if ( li > 6 ) break;
					if ( !item.IsAvailable( slot ) ) continue;
					if ( result == uint(li) ) return item;
					li++;
				}
				return null;
			}

			string GetSlotName( int slot )
			{
				string slot_name = "wrong slot";
				switch( slot )
				{
					case WEP_SLOT_PRIMARY: slot_name = "Primary Weapon"; break;
					case WEP_SLOT_SECONDARY: slot_name = "Secondary Weapon"; break;
					case WEP_SLOT_SPECIAL: slot_name = "Special Weapon"; break;
				}
				return slot_name;
			}

			void ExecuteArgument( CTerrorPlayer@ pPlayer, uint page, uint result, uint slot )
			{
				CWeaponItem @item = GetFromResult( page, result, slot );
				if ( item is null ) return;
				if ( Utils.StrEql( item.weapon, "" ) ) return;
				DeathMatch::GunMenu::AddToGunSlot( pPlayer, slot, item.weapon );
				pPlayer.RemoveWeapon( slot - 1 );
				pPlayer.GiveWeapon( item.weapon );
				Chat.PrintToChat( pPlayer, "{gold}[{green}DM{gold}]{white} Selected {gold}" + item.name );
				if ( slot < WEP_SLOT_SPECIAL )
					OnPageChanged( pPlayer, 0, slot+1 );
			}

			void OnPageChanged( CTerrorPlayer @pPlayer, uint page, int slot )
			{
				Menu pMenu;
				FillWeapons( pMenu, page, slot );
				pMenu.SetID( m_ID + ";" + page + ";" + slot );
				pMenu.SetTitle( m_Name + " - " + GetSlotName( slot ) );
				pMenu.Display( pPlayer, -1 );
			}

			void OnMenuExecuted( CTerrorPlayer@ pPlayer, CASCommand @pArgs, int &in iValue ) override
			{
				string arg0 = pArgs.Arg( 0 );	// MainID
				string arg1 = pArgs.Arg( 1 );	// Page
				string arg2 = pArgs.Arg( 2 );	// Slot
				uint page = parseUInt( arg1 );
				uint slot = parseUInt( arg2 );
				uint result = iValue - 1; // Reduce 1 for the result
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
						ExecuteArgument( pPlayer, page, result, slot );
					}
					break;
					case 8:
					{
						if ( page > 1 )
							OnPageChanged( pPlayer, CalculatePageCount( false, page - 6, slot ), slot );
						else
							GoBack( pPlayer );
					}
					break;
					case 9:
					{
						OnPageChanged( pPlayer, CalculatePageCount( true, page + 6, slot ), slot );
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

		//------------------------------------------------------------------------------------------------------------------------//

		class PlayerChoosenWeapon
		{
			string m_slot1;
			string m_slot2;
			string m_slot3;
			string m_slot4;
			int m_PlayerIndex;
			PlayerChoosenWeapon(const int &in iPlayer)
			{
				m_PlayerIndex = iPlayer;
				m_slot1 = m_slot2 = m_slot3 = "";
			}
		}
		array<PlayerChoosenWeapon@> s_PlayerList;

		//------------------------------------------------------------------------------------------------------------------------//

		void ClearIffound( CTerrorPlayer @pPlayer )
		{
			int client = pPlayer.entindex();
			for ( uint i = 0; i < s_PlayerList.length(); i++ )
			{
				PlayerChoosenWeapon @item = s_PlayerList[i];
				if ( client == item.m_PlayerIndex )
				{
					s_PlayerList.removeAt( i );
					return;
				}
			}
		}

		//------------------------------------------------------------------------------------------------------------------------//

		bool HasAlreadyGuns( CTerrorPlayer @pPlayer )
		{
			PlayerChoosenWeapon @item = GrabPlayerGuns( pPlayer );
			if ( item is null ) return false;
			return true;
		}

		//------------------------------------------------------------------------------------------------------------------------//

		PlayerChoosenWeapon @GrabPlayerGuns( CTerrorPlayer @pPlayer )
		{
			int client = pPlayer.entindex();
			for ( uint i = 0; i < s_PlayerList.length(); i++ )
			{
				PlayerChoosenWeapon @item = s_PlayerList[i];
				if ( client == item.m_PlayerIndex )
					return item;
			}
			return null;
		}

		//------------------------------------------------------------------------------------------------------------------------//

		void AddToGunSlot( CTerrorPlayer @pPlayer, const int &in slot, const string &in szWeapon )
		{
			PlayerChoosenWeapon @item = GrabPlayerGuns( pPlayer );
			if ( item is null )
			{
				@item = PlayerChoosenWeapon( pPlayer.entindex() );
				s_PlayerList.insertLast( item );
			}
			switch( slot )
			{
				case 1: item.m_slot1 = szWeapon; break;
				case 2: item.m_slot2 = szWeapon; break;
				case 3: item.m_slot3 = szWeapon; break;
				case 4: item.m_slot4 = szWeapon; break;
			}
		}

		//------------------------------------------------------------------------------------------------------------------------//

		void DrawOnFirstSpawn( CTerrorPlayer @pPlayer )
		{
			// If we already spawned, then we show this!
			// Else, just grab what we picked earlier.
			if ( !HasAlreadyGuns( pPlayer ) )
				Draw( pPlayer );
			else
			{
				PlayerChoosenWeapon @item = GrabPlayerGuns( pPlayer );
				if ( item is null ) return;
				for ( uint i = 1; i < 4; i++ )
				{
					string szWeapon = "";
					switch( i )
					{
						case 1: szWeapon = item.m_slot1; break;
						case 2: szWeapon = item.m_slot2; break;
						case 3: szWeapon = item.m_slot3; break;
						case 4: szWeapon = item.m_slot4; break;
					}
					if ( Utils.StrEql( szWeapon, "" ) ) return;
					pPlayer.RemoveWeapon( i - 1 );
					pPlayer.GiveWeapon( szWeapon );
				}
			}
		}
	}
}