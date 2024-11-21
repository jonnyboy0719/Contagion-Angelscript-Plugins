//------------------------------------------------------------------------------------------------------------------------//
// Interface
#include "admin/shared/interface.as"
#include "../maps/util.as"

//------------------------------------------------------------------------------------------------------------------------//
// Import
import void AdminMenu_RegisterItem( IAdminMenuItemBase @module ) from "adminmenu.as";
import void AdminMenu_RemoveItem( string module_id ) from "adminmenu.as";
import void AdminMenu_BackToGroup( CTerrorPlayer@ pPlayer, int group ) from "adminmenu.as";

//------------------------------------------------------------------------------------------------------------------------//
// Main
class CMenuItem : CAdminMenuItemTargetBase
{
	private array<int> m_Beacons;
	private int m_BeamSprite;
	private int m_HaloSprite;

	CMenuItem()
	{
		m_ID = "as_beacon";
		m_Name = "Beacon player";
		m_Group = GROUP_PLAYER_CMD;
		m_Level = LEVEL_ADMIN;

		// Precache and set the sprites
		m_BeamSprite = Engine.PrecacheFile( model, "sprites/laserbeam.vmt" );
		m_HaloSprite = Engine.PrecacheFile( model, "sprites/lgtning.vmt" );
	}

	void BeaconBleep( int client )
	{
		if ( !IsClientAlreadyInArray( client ) )
			return;
		
		CTerrorPlayer@ pTerror = ToTerrorPlayer( client );
		if ( pTerror is null )
		{
			RemoveFromList( client );
			return;
		}
		
		Vector vOrigin = pTerror.GetAbsOrigin();
		vOrigin.z += 10;
		
		Color clr = Color( 255, 75, 75, 255 );
		if ( pTerror.GetTeamNumber() == TEAM_SURVIVOR )
			clr = Color( 75, 75, 255, 255 );
		
		// Write and send temporary data information to the client side
		Utils.CreateBeamRingPoint( 0.0f, vOrigin, Color( 128, 128, 128, 255 ), 10.0f, 375.0f, m_BeamSprite, m_HaloSprite, 0, 15, 0.5f, 5.0f, 0.0f, 10.0, 0, 0 );
		Utils.CreateBeamRingPoint( 0.0f, vOrigin, clr, 10.0, 375.0f, m_BeamSprite, m_HaloSprite, 0, 10, 0.6, 10.0, 0.5, 10, 0, 0 );
		
		// Play a sound
		UTIL_PlayWwiseSoundID( "SFX_BUTTON_BEEP_01", client );
		Schedule::Task( 1.0, client, DoBeaconBleep );
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

	bool IsClientAlreadyInArray( int client )
	{
		for ( uint n = 0; n < m_Beacons.length(); n++ )
		{
			if ( m_Beacons[n] == client ) return true;
		}
		return false;
	}

	void RemoveFromList( int client )
	{
		for ( uint n = 0; n < m_Beacons.length(); n++ )
		{
			if ( m_Beacons[n] == client )
			{
				m_Beacons.removeAt( n );
				break;
			}
		}
	}

	void ExecuteArgument( CTerrorPlayer@ pPlayer, uint result )
	{
		CTerrorPlayer @pTerror = GetPlayerFromResult( result );
		if ( pTerror is null ) return;
		string szName = pTerror.GetPlayerName();

		// Only beacon if they are alive
		if ( !pTerror.IsAlive() )
		{
			Chat.PrintToChat( pPlayer, "{gold}[{green}AS{gold}]{red} Can't beacon target {orange}" + szName + " {red}because they are not alive." );
			return;
		}

		int client = pTerror.entindex();
		if ( IsClientAlreadyInArray( client ) )
			RemoveFromList( client );
		else
		{
			m_Beacons.insertLast( client );
			Schedule::Task( 1.0, client, DoBeaconBleep );
		}

		Chat.PrintToChat( pPlayer, "{gold}[{green}AS{gold}]{white} Toggled beacon for " + szName );
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

void DoBeaconBleep( int client )
{
	pMenuItem.BeaconBleep( client );
}

void OnPluginInit()
{
	PluginData::SetVersion( "1.0" );
	PluginData::SetAuthor( "JonnyBoy0719" );
	PluginData::SetName( "Admin Beacon Command" );

	// Make sure adminmenu is loaded
	if ( !PluginData::IsLoaded( "adminmenu" ) )
	{
		throw( "The beacon plugin requires \"{gold}adminmenu{default}\" to be fully loaded!" );
		return;
	}

	AdminMenu_RegisterItem( pMenuItem );
}

void OnPluginUnload()
{
	AdminMenu_RemoveItem( pMenuItem.GetID() );
}