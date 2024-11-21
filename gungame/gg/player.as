#include "player_base.as"
namespace GunGame
{
    namespace Player
    {
        int iMaxPlayers;
        
        void ClearData()
        {
            iMaxPlayers = Globals.GetMaxClients();
            gg_players.resize(iMaxPlayers + 1); 
        }
        
        void Reset()
        {
            for ( uint i = 0; i < gg_players.length(); i++ )
            {
                CGunGamePlayer@ pGGPlayer = gg_players[i];
                if ( pGGPlayer is null ) continue;
                pGGPlayer.Reset();
            }
            GunGame::ResetLeader();
        }
        
        void RespawnWeapons()
        {
            for ( uint i = 0; i < gg_players.length(); i++ )
            {
                CGunGamePlayer@ pGGPlayer = gg_players[i];
                if ( pGGPlayer is null ) continue;
                pGGPlayer.GiveWeapons();
            }
        }
        
        void Spawned( int player_index )
        {
			CTerrorPlayer @pTerror = ToTerrorPlayer( player_index );
			if ( pTerror !is null )
				pTerror.StripEquipment( true );
            Schedule::Task( 0.1f, player_index, GunGame::Player::DelayedGiveWeapons );
        }
		
		void DelayedGiveWeapons( int player_index )
		{
			CGunGamePlayer@ pGGPlayer = gg_players[player_index];
            if ( pGGPlayer is null ) return;
            pGGPlayer.GiveWeapons();
		}
        
        bool HasDMGFlag( int flags, int flag )
        {
            return ((flags&flag) == flag);
        }
        
        void KilledPlayer( int victim, int attacker, int flags )
        {
            // We died, remove the glow!
            GunGame::RemoveGlow( gg_players[victim] );
            // Our victim was killed with a melee?
            bool bMelee = false;
            // Check if our player is valid
            CTerrorPlayer @pTerror = ToTerrorPlayer( victim );
            if ( pTerror !is null )
            {
                // If our player got a grenade, drop it!
                if ( pTerror.GetWeaponSlot( "weapon_grenade" ) != -1 )
                    CreateGrenadeOnDeath( pTerror );
            }
            if ( HasDMGFlag( flags, DMG_CLUB ) || HasDMGFlag( flags, DMG_SLASH ) )
            {
                CGunGamePlayer@ pGGPlayer = gg_players[victim];
                if ( pGGPlayer !is null )
                {
                    pGGPlayer.KilledByMelee();
                    // If the victim got melee'd, make sure both the killer and victim is valid
                    if ( pGGPlayer.CurrentLevel() > 1 )
                    {
                        bMelee = true;
                        CTerrorPlayer @pTerrorKiller = ToTerrorPlayer( attacker );
                        if ( pTerrorKiller !is null )
                        {
                            CBasePlayer@ pBasePlayer = pTerrorKiller.opCast();
                            Chat.PrintToChat( pBasePlayer, "{azure}You stole a level from {green}" + pTerror.GetPlayerName() + "{default}!" );
                        }
                    }
                }
            }
            bool bSelfKill = false;
            if ( victim == attacker )
                bSelfKill = true;
            CGunGamePlayer@ pGGPlayer = gg_players[attacker];
            if ( pGGPlayer is null ) return;
            pGGPlayer.OnKilledPlayer(bSelfKill, bMelee);
        }

        void CreateGrenadeOnDeath( CTerrorPlayer @pTerror )
        {
            Vector vPos = pTerror.GetAbsOrigin();
            vPos += Vector( 0, 0, 8 );
            QAngle vAng = pTerror.GetAbsAngles();
            Utils.SpawnGrenade( pTerror, vPos, Vector(), vAng, 2.0f );
        }

        void AnnounceKiller( int killer )
        {
            if ( CheckForNewLeader( gg_players[killer] ) ) return;
            CGunGamePlayer @pLeader = GunGame::GetLeader();
            int leader_level = pLeader.level;
            CTerrorPlayer@ pTerrorPlayer = ToTerrorPlayer( killer );
            // The killer is the leader, announce their success
            if ( killer == pLeader.PlayerIndex )
            {
                leader_level += 1;
                Chat.PrintToChat( all, "{azure}" + pTerrorPlayer.GetPlayerName() + " {green}is leading on level {default}" + leader_level );
            }
            // Not the leader, check if they are tied
            else
            {
                CGunGamePlayer @pPlayer = gg_players[killer];
                int lvl_behind = leader_level - pPlayer.level;
                if ( lvl_behind == 0 )
                    Chat.PrintToChat( all, "{azure}" + pTerrorPlayer.GetPlayerName() + " {green}is tied with the leader on level {default}" + pPlayer.CurrentLevel() );
                else
                    GunGame::Player::CheckStatus( killer, false );
            }
        }

        string GetSuffix( int n )
        {
            if ( n % 100 == 11 || n % 100 == 12 || n % 100 == 13 )
                return "{azure}" + n + "th";
            else
            {
                if ( n % 10 == 1 )
                    return "{green}" + n + "st";
                else
                {
                    if ( n % 10 == 2 )
                        return "{orange}" + n + "nd";
                    else
                    {
                        if ( n % 10 == 3 )
                            return "{yellow}" + n + "rd";
                        else
                        {
                            if ( n % 10 == 4 || n % 10 == 5 || n % 10 == 6 || n % 10 == 7 || n % 10 == 8 || n % 10 == 9 || n % 10 == 0 )
                                return "{azure}" + n + "th";
                        }
                    }
                }
            }
            return "{azure}" + n;
        }

        void CheckStatus( int player, bool fromcommand )
        {
            CTerrorPlayer@ pTerrorPlayer = ToTerrorPlayer( player );
            CBasePlayer@ pBasePlayer = pTerrorPlayer.opCast();
            CGunGamePlayer @pPlayer = gg_players[player];
            CGunGamePlayer @pLeader = GunGame::GetLeader();
            if ( fromcommand )
            {
                if ( pPlayer is null )
                {
                    Chat.PrintToChat( pBasePlayer, "{azure}Player is invalid, and thus cannot display the status." );
                    return;
                }
                if ( pLeader is null )
                    @pLeader = pPlayer;

                string szPosition = "{green}1st";
                int leader_index = pLeader.PlayerIndex;
                int leader_level = pLeader.level;
                int lvl_behind = leader_level - pPlayer.level;
                if ( lvl_behind > 0 )
                    szPosition = GetSuffix( lvl_behind+1 );
                else
                {
                    if ( leader_index != player )
                        szPosition = "{gold}Tied";
                }

                int player_level = pPlayer.level;
                int player_kills = pPlayer.kills;
                Chat.PrintToChat(
                    pBasePlayer,
                    "{default}Position{white}: " + szPosition + "\n{default}Level{white}: {gold}" + formatInt( player_level )
                );
                Chat.PrintToChat(
                    pBasePlayer,
                    "{default}Progress{white}: {gold}" + player_kills + " {green}/ {gold}" + GunGame::Guns::GetNeededKills( player_level )
                );
            }
            else
            {
                if ( pLeader !is null )
                {
                    int leader_level = pLeader.level;
                    int lvl_behind = leader_level - pPlayer.level;
                    if ( lvl_behind > 0 )
                    {
                        string szLevels;
                        if ( lvl_behind > 1 )
                            szLevels = "levels";
                        else
                            szLevels = "level";
                        Chat.PrintToChat( pBasePlayer, "{azure}You are {green}" + lvl_behind + " {azure}" + szLevels + " behind the leader!" );
                    }
                }
            }
        }
    }
}