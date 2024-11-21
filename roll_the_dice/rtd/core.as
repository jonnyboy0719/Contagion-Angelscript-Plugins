//------------------------------------------------------------------------------------------------------------------------//
// Base Type
#include "type_base.as"
#include "menu.as"

//------------------------------------------------------------------------------------------------------------------------//
// Core classes

class CRTDPlayer
{
	IRollTheDiceTypeBase @m_pPerk;
	float m_flPerkTime;
	int m_iPlayer;
	bool m_IsActive;
	CRTDPlayer( IRollTheDiceTypeBase @pPerk, int client )
	{
		@m_pPerk = pPerk;
		m_flPerkTime = Globals.GetCurrentTime() + pPerk.GetTime();
		m_iPlayer = client;
		m_IsActive = true;
	}
	CRTDPlayer( IRollTheDiceTypeBase @pPerk, int client, float flCustomTime )
	{
		@m_pPerk = pPerk;
		m_flPerkTime = Globals.GetCurrentTime() + flCustomTime;
		m_iPlayer = client;
		m_IsActive = true;
	}
}

class CRTDSystem
{
	//------------------------------------------------------------------------------------------------------------------------//

	uint length() { return items.length(); }

	IRollTheDiceTypeBase @GetItemFromResult( uint result )
	{
		uint li = 0;
		for ( uint i = 0; i < items.length(); i++ )
		{
			IRollTheDiceTypeBase @pItem = items[i];
			if ( pItem is null ) continue;
			if ( result == li ) return pItem;
			li++;
		}
		return null;
	}

	IRollTheDiceTypeBase @GetItemFromResult( string ItemName )
	{
		for ( uint i = 0; i < items.length(); i++ )
		{
			IRollTheDiceTypeBase @pItem = items[i];
			if ( pItem is null ) continue;
			if ( Utils.StrEql( ItemName, pItem.GetID() ) ) return pItem;
		}
		return null;
	}

	//------------------------------------------------------------------------------------------------------------------------//

	bool CanRollDice( bool bIsForced, CTerrorPlayer@ pPlayer, bool &out bActive, float &out flTime )
	{
		if ( bIsForced ) return true;
		for ( uint i = 0; i < players.length(); i++ )
		{
			CRTDPlayer @pRTDPlayer = players[i];
			if ( pRTDPlayer is null ) continue;
			if ( pRTDPlayer.m_iPlayer == pPlayer.entindex() )
			{
				flTime = pRTDPlayer.m_flPerkTime;
				bActive = pRTDPlayer.m_IsActive;
				return false;
			}
		}
		flTime = 0.0f;
		bActive = false;
		return true;
	}

	//------------------------------------------------------------------------------------------------------------------------//

	CRTDPlayer @GrabActivePlayerPerk( int client )
	{
		for ( uint i = 0; i < players.length(); i++ )
		{
			CRTDPlayer @pRTDPlayer = players[i];
			if ( pRTDPlayer is null ) continue;
			if ( pRTDPlayer.m_iPlayer == client ) return pRTDPlayer;
		}
		return null;
	}

	//------------------------------------------------------------------------------------------------------------------------//

	string RTDPlayerName( CTerrorPlayer@ pPlayer ) { return "{team}" + pPlayer.GetPlayerName() + "{white}"; }

	//------------------------------------------------------------------------------------------------------------------------//

	void RTDPrint( CTerrorPlayer@ pPlayer, string &in msg )
	{
		if ( pPlayer.IsBot() ) return;
		Chat.PrintToChat( pPlayer, "{gold}[RTD] {white}" + msg );
	}

	//------------------------------------------------------------------------------------------------------------------------//

	void RTDPrint( string &in msg )
	{
		Chat.PrintToChat( all, "{gold}[RTD] {white}" + msg );
	}

	//------------------------------------------------------------------------------------------------------------------------//

	void RTDPrintOthers( CTerrorPlayer@ pPlayer, string &in msg1, string &in msg2 )
	{
		for ( int x = 0; x < Globals.GetMaxClients(); x++ )
		{
			CTerrorPlayer@ pTarget = ToTerrorPlayer(x);
			if ( pTarget is null ) continue;
			if ( pTarget.entindex() != pPlayer.entindex() )
				Chat.PrintToChat( pTarget, "{gold}[RTD] {white}" + msg2 );
			else
				Chat.PrintToChat( pPlayer, "{gold}[RTD] {white}" + msg1 );
		}
	}

	//------------------------------------------------------------------------------------------------------------------------//

	bool CheckIfPlayerCanRoll( CTerrorPlayer@ pPlayer, bool bIsForced, CTerrorPlayer@ pAdmin = null )
	{
		bool bActive;
		float flTime;
		CTerrorPlayer@ pTarget = pAdmin;
		if ( pTarget is null )
			@pTarget = pPlayer;
		if ( !CanRollDice( bIsForced, pPlayer, bActive, flTime ) )
		{
			if ( bActive )
				RTDPrint( pTarget, "You are already using RTD." );
			else
			{
				flTime -= Globals.GetCurrentTime();
				RTDPrint( pTarget, "You must wait {arcana}" + formatFloat(flTime, '0', 2, 1) + " {white}second(s)." );
			}
			return false;
		}
		else if ( !pPlayer.IsAlive() )
		{
			RTDPrint( pTarget, "You must be alive to use RTD." );
			return false;
		}
		return true;
	}

	//------------------------------------------------------------------------------------------------------------------------//

	void ExecuteRandomPerk( CTerrorPlayer@ pPlayer )
	{
		if ( !CheckIfPlayerCanRoll( pPlayer, false ) ) return;

		// The client that will get the perk
		int client = pPlayer.entindex();

		// Grab a random perk
		IRollTheDiceTypeBase @pItem = items[Math::RandomInt( 0, items.length() - 1 )];
		players.insertLast( CRTDPlayer( pItem, client ) );

		// What did we roll?
		ExecutePlayerPerk( client );
	}

	//------------------------------------------------------------------------------------------------------------------------//

	void ExecutePerk( CTerrorPlayer@ pAdmin, CTerrorPlayer@ pPlayer, string ItemName, float flDuration )
	{
		if ( ItemName.isEmpty() || pPlayer is null )
		{
			if ( pPlayer is null )
				RTDPrint( pAdmin, "{red}The targeted player does not exist." );
			else
				RTDPrint( pAdmin, "{red}You need to specify the perk." );
			RTDPrint( pAdmin, "as_forcertd <player> <perk> [perk_time]" );
			return;
		}
		if ( !CheckIfPlayerCanRoll( pPlayer, true, pAdmin ) ) return;

		// Grab our perk
		IRollTheDiceTypeBase @pItem = GetItemFromResult( ItemName );
		if ( pItem is null )
		{
			RTDPrint( pAdmin, "The perk {arcana}" + ItemName + " {white}does not exist." );
			return;
		}

		// The client that will get the perk
		int client = pPlayer.entindex();
		CRTDPlayer @pRTDPlayer = null;
		if ( flDuration > 0.0f )
			@pRTDPlayer = CRTDPlayer( pItem, client, flDuration );
		else
			@pRTDPlayer = CRTDPlayer( pItem, client );

		players.insertLast( pRTDPlayer );

		// What did we roll?
		ExecutePlayerPerk( pRTDPlayer );
	}

	//------------------------------------------------------------------------------------------------------------------------//

	string GetPerkColor( PerkType eType )
	{
		switch( eType )
		{
			case k_eBad: return "{red}";
			case k_eNeutral: return "{valve}";
			case k_eGood: return "{lime}";
		}
		return "{white}";
	}

	//------------------------------------------------------------------------------------------------------------------------//

	void ExecutePlayerPerk( CRTDPlayer @pPerk )
	{
		// Our client
		CTerrorPlayer@ pTarget = ToTerrorPlayer(pPerk.m_iPlayer);

		// Announce what perk we got
		string msg = RTDPlayerName( pTarget ) + " force rolled " + GetPerkColor( pPerk.m_pPerk.GetPerkType() ) + pPerk.m_pPerk.GetName();
		RTDPrint( msg );

		// Activate it
		pPerk.m_pPerk.OnRollStart( pTarget );
	}

	//------------------------------------------------------------------------------------------------------------------------//

	void ExecutePlayerPerk( int client )
	{
		// Our active player perk
		CRTDPlayer @pPerk = GrabActivePlayerPerk(client);

		// Our client
		CTerrorPlayer@ pTarget = ToTerrorPlayer(client);

		// Announce what perk we got
		string msg = RTDPlayerName( pTarget ) + " rolled " + GetPerkColor( pPerk.m_pPerk.GetPerkType() ) + pPerk.m_pPerk.GetName();
		RTDPrint( msg );

		// Activate it
		pPerk.m_pPerk.OnRollStart( pTarget );
	}

	//------------------------------------------------------------------------------------------------------------------------//

	void EndPerk( CTerrorPlayer@ pPlayer, PerkState ePerk )
	{
		if ( pPlayer is null ) return;
		// Our active player perk
		CRTDPlayer @pPerk = GrabActivePlayerPerk( pPlayer.entindex() );
		if ( pPerk is null ) return;
		// If not active, then ignore
		if ( !pPerk.m_IsActive ) return;
		switch( ePerk )
		{
			case k_eEnded:
			{
				if ( !pPerk.m_pPerk.NoRollEndNotify() )
					RTDPrintOthers( pPlayer, "Your perk has worn off.", RTDPlayerName( pPlayer ) + "'s perk has worn off." );
			}
			break;
			case k_eKilled: RTDPrintOthers( pPlayer, "You have died during your roll", RTDPlayerName( pPlayer ) + " has died during their roll" ); break;
			case k_eDisconnected: RTDPrint( RTDPlayerName( pPlayer ) + " has disconnected during their roll." ); break;
		}
		// End it
		pPerk.m_pPerk.OnRollEnd( pPlayer, ePerk );
		pPerk.m_flPerkTime = Globals.GetCurrentTime() + 10.0f;
		pPerk.m_IsActive = false;
	}

	//------------------------------------------------------------------------------------------------------------------------//

	void OnFireGameEvent( ASGameEvent &in event )
	{
		for ( uint i = 0; i < items.length(); i++ )
		{
			IRollTheDiceTypeBase @pItem = items[i];
			if ( pItem is null ) continue;
			pItem.OnFireGameEvent( event );
		}
	}

	//------------------------------------------------------------------------------------------------------------------------//

	void Think()
	{
		if ( pRTD_AutoBots.GetBool() )
			DoBotsRTD();
		for ( uint i = 0; i < players.length(); i++ )
		{
			CRTDPlayer @pRTDPlayer = players[i];
			if ( pRTDPlayer is null ) continue;
			float flTime = pRTDPlayer.m_flPerkTime - Globals.GetCurrentTime();
			if ( flTime < 0.0f )
			{
				if ( pRTDPlayer.m_IsActive )
				{
					g_rtd.EndPerk( ToTerrorPlayer(pRTDPlayer.m_iPlayer), k_eEnded );
					continue;
				}
				players.removeAt( i );
			}
			else
			{
				// Show how much time we have left for our perk, if NoRollEndNotify is not enabled
				if ( !pRTDPlayer.m_pPerk.NoRollEndNotify() && pRTDPlayer.m_IsActive )
				{
					int seconds, hours, minutes;
					seconds = int(flTime);
					minutes = seconds / 60;
					hours = minutes / 60;
					string remaining_time = "00:00";
					if ( hours > 0 )
						remaining_time = formatInt( hours, '0', 1 ) + ":" + formatInt( int(minutes%60), '0', 2 ) + ":" + int(seconds%60);
					else
						remaining_time = formatInt( int(minutes%60), '0', 2 ) + ":" + formatInt( int(seconds%60), '0', 2 );
					Chat.HintMessagePlayer( pRTDPlayer.m_iPlayer, pRTDPlayer.m_pPerk.GetName() + ": " + remaining_time, Color( 0, 255, 0 ) );
				}
			}
		}
	}

	//------------------------------------------------------------------------------------------------------------------------//

	bool CanExecutePerk( int bot )
	{
		if ( bot_rtd.exists('bot_' + bot) )
		{
			float flTime = float( bot_rtd['bot_' + bot] );
			if ( flTime > Globals.GetCurrentTime() ) return false;
			bot_rtd['bot_' + bot] = Globals.GetCurrentTime() + Math::RandomFloat( 10.0f, 55.0f );
			return true;
		}
		bot_rtd.set('bot_' + bot, Globals.GetCurrentTime() + Math::RandomFloat( 8.0f, 25.0f ) );
		return false;
	}

	//------------------------------------------------------------------------------------------------------------------------//

	void DoBotsRTD()
	{
		array<int> collector = Utils.CollectPlayers();
		if ( collector.length() > 0 )
		{
			// Go trough our collector
			CTerrorPlayer@ pTerror = null;
			for ( uint i = 0; i < collector.length(); i++ )
			{
				@pTerror = ToTerrorPlayer( collector[ i ] );
				if ( pTerror is null ) continue;
				if ( !pTerror.IsAlive() ) continue;
				if ( !pTerror.IsBot() ) continue;
				if ( !CanExecutePerk( pTerror.entindex() ) ) continue;
				ExecuteRandomPerk( pTerror );
			}
		}
	}

	//------------------------------------------------------------------------------------------------------------------------//

	void Clear()
	{
		for ( uint i = 0; i < items.length(); i++ )
		{
			IRollTheDiceTypeBase @pItem = items[i];
			if ( pItem is null ) continue;
			pItem.ClearData();
		}
		players.removeRange(0, players.length() - 1);
	}

	//------------------------------------------------------------------------------------------------------------------------//

	void RegisterItem( IRollTheDiceTypeBase @module )
	{
		items.insertLast( module );
	}

	//------------------------------------------------------------------------------------------------------------------------//

	HookReturnCode OnPlayerDamagedPre(CTerrorPlayer@ pPlayer, CTakeDamageInfo &in DamageInfo)
	{
		CBaseEntity @pAttacker = DamageInfo.GetAttacker();
		if ( pAttacker !is null )
		{
			for ( uint i = 0; i < players.length(); i++ )
			{
				CRTDPlayer @pRTDPlayer = players[i];
				if ( pRTDPlayer is null ) continue;
				if ( pRTDPlayer.m_iPlayer == pAttacker.entindex() ) return pRTDPlayer.m_pPerk.OnPlayerDamagedPre( pPlayer, DamageInfo );
			}
		}
		return HOOK_CONTINUE;
	}

	//------------------------------------------------------------------------------------------------------------------------//

	HookReturnCode OnInfectedDamagedPre(Infected@ pInfected, CTakeDamageInfo &in DamageInfo)
	{
		CBaseEntity @pAttacker = DamageInfo.GetAttacker();
		if ( pAttacker !is null )
		{
			for ( uint i = 0; i < players.length(); i++ )
			{
				CRTDPlayer @pRTDPlayer = players[i];
				if ( pRTDPlayer is null ) continue;
				if ( pRTDPlayer.m_iPlayer == pAttacker.entindex() ) return pRTDPlayer.m_pPerk.OnInfectedDamagedPre( pInfected, DamageInfo );
			}
		}
		return HOOK_CONTINUE;
	}

	//------------------------------------------------------------------------------------------------------------------------//

	void RemoveItem( string module_id )
	{
		int index = -1;
		for ( uint i = 0; i < items.length(); i++ )
		{
			IRollTheDiceTypeBase @pItem = items[i];
			if ( pItem is null ) continue;
			if ( !Utils.StrEql( module_id, pItem.GetID() ) ) continue;
			index = i;
			break;
		}
		if ( index < 0 ) return;
		items.removeAt( index );
		Log.PrintToServerConsole( LOGTYPE_INFO, "Removed Perk [{gold}" + module_id + "{default}]");
	}

	//------------------------------------------------------------------------------------------------------------------------//
	// Private accessors
	private dictionary bot_rtd;
	private array<IRollTheDiceTypeBase@> items;
	private array<CRTDPlayer@> players;
}
CRTDSystem @g_rtd = CRTDSystem();