#include "events/player_spawn"
#include "events/player_protected"
#include "events/player_revived"
#include "events/player_grapple"
#include "events/map_transition"
#include "events/game_end"
#include "events/round_end"
#include "events/zombie_crippled"

//------------------------------------------------------------------------------------------------------------------------//

funcdef void GameEventFunctor(ASGameEvent &in event);

class GameEventItem
{
    string EventName;
    GameEventFunctor @Func;
    GameEventItem( string &in szEventName, GameEventFunctor @func )
    {
        EventName = szEventName;
        @Func = func;
        g_GameEventManager.AddEvent( this );
    }
}

class GameEventManager
{
    array<GameEventItem@> m_List;
    void AddEvent( GameEventItem @pItem )
    {
        m_List.insertLast( pItem );
    }

    void FireEvent( ASGameEvent &in event )
    {
        for ( uint i = 0; i < m_List.length(); i++ )
        {
            GameEventItem @handle = m_List[i];
            if ( handle is null ) continue;
            if ( Utils.StrEql( event.GetName(), handle.EventName ) )
            {
                handle.Func( event );
                break;
            }
        }
    }
}
GameEventManager @g_GameEventManager = GameEventManager();

//------------------------------------------------------------------------------------------------------------------------//

void RegisterEvents()
{
    GameEventItem( "player_spawn", Event_PlayerSpawned );
    GameEventItem( "player_protected", Event_PlayerProtected );
    GameEventItem( "player_revived", Event_PlayerRevived );
    GameEventItem( "player_grapple", Event_PlayerGrappled );
    GameEventItem( "map_transition", Event_MapTransition );
    GameEventItem( "game_end", Event_GameEnd );
    GameEventItem( "round_end", Event_RoundEnd );
    GameEventItem( "zombie_crippled", Event_ZombieCrippled );
}

//------------------------------------------------------------------------------------------------------------------------//

void OnFireGameEvent( ASGameEvent &in event, bool &in bClientsided )
{
    if ( bClientsided ) return;
    g_GameEventManager.FireEvent( event );
}
