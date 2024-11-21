//------------------------------------------------------------------------------------------------------------------------//
// Interface
#include "admin/shared/interface.as"

//------------------------------------------------------------------------------------------------------------------------//
// Import
import void AdminMenu_RegisterItem( IAdminMenuItemBase @module ) from "adminmenu.as";
import void AdminMenu_RemoveItem( string module_id ) from "adminmenu.as";
import void AdminMenu_BackToGroup( CTerrorPlayer@ pPlayer, int group ) from "adminmenu.as";

//------------------------------------------------------------------------------------------------------------------------//
// Main
class CMenuItem : CAdminMenuItemTargetBase
{
	CMenuItem()
	{
		m_ID = "as_noclip";
		m_Name = "Noclip player";
		m_Group = GROUP_PLAYER_CMD;
		m_Level = LEVEL_ADMIN;
	}

	void OnItemOpen( CTerrorPlayer @pPlayer ) override
	{
		OnPageChanged( pPlayer, 1 );
	}

	void OnPageChanged( CTerrorPlayer @pPlayer, uint page )
	{
		Menu pMenu;
		FillPlayers( pMenu, page );
		pMenu.SetID( m_ID + ";" + page );
		pMenu.SetTitle( m_Name );
		pMenu.SetBack( true );
		pMenu.Display( pPlayer, -1 );
	}

	void ExecuteArgument( CTerrorPlayer@ pPlayer, uint result )
	{
		CTerrorPlayer @pTerror = GetPlayerFromResult( result );
		if ( pTerror is null ) return;
		string szName = pTerror.GetPlayerName();

		// Only toggle noclip if we are alive
		if ( !pTerror.IsAlive() )
		{
			Chat.PrintToChat( pPlayer, "{gold}[{green}AS{gold}]{red} Can't noclip target {orange}" + szName + " {red}because they are not alive." );
			return;
		}

		MoveType_t movetype = pTerror.GetMoveType();
		if ( movetype != MOVETYPE_NOCLIP )
			movetype = MOVETYPE_NOCLIP;
		else
			movetype = MOVETYPE_WALK;

		Chat.PrintToChat( pPlayer, "{gold}[{green}AS{gold}]{white} Toggled noclip for " + szName );
		pTerror.SetMoveType( movetype );
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
				ExecuteArgument( pPlayer, result );
				OnPageChanged( pPlayer, page );
			}
			break;
			case 8:
			{
				if ( page > 1 )
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

void OnPluginInit()
{
	PluginData::SetVersion( "1.0" );
	PluginData::SetAuthor( "JonnyBoy0719" );
	PluginData::SetName( "Admin Noclip Command" );

	// Make sure adminmenu is loaded
	if ( !PluginData::IsLoaded( "adminmenu" ) )
	{
		throw( "The noclip plugin requires \"adminmenu\" to be fully loaded!" );
		return;
	}

	AdminMenu_RegisterItem( pMenuItem );
}

void OnPluginUnload()
{
	AdminMenu_RemoveItem( pMenuItem.GetID() );
}