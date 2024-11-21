#include "gg/music.as"
#include "gg/core.as"
#include "gg/core_cvars.as"
#include "gg/guns.as"
#include "gg/player.as"
#include "gg/manager.as"
#include "gg/hud.as"

/*
array<string> arrChristmasProps = {
    "models/christmas/w_zombie_christmas_antlers/w_zombie_xmas_antlers.mdl",
    "models/christmas/w_zombie_christmas_hat/w_zombie_christmas_hat.mdl",
    "models/christmas/w_zombie_christmas_nose/w_zombie_xmas_nose.mdl",
    "models/christmas/w_zombie_christmas_wreath/w_zombie_xmas_wreath.mdl",
};
*/

void OnPluginInit()
{
    PluginData::SetVersion( "1.5" );
    PluginData::SetAuthor( "JonnyBoy0719" );
    PluginData::SetName( "GunGame" );

    GunGame::Cvars::Init();

    HuntedDMSetup();
    SetSomeGameRules();

    Events::ThePresident::OnRandomItemSpawn.Hook( @OnRandomItemSpawn_GG );
    Events::ThePresident::OnTerminateRound.Hook( @OnTerminateRound_GG );

    Events::Entities::OnEntityCreation.Hook( @OnEntCreated_GG );
    
    Events::Player::OnPlayerConnected.Hook( @OnPlayerConnected_GG );
    Events::Player::OnPlayerSpawn.Hook( @OnPlayerSpawn_GG );
    Events::Player::OnPlayerKilled.Hook( @OnPlayerKilled_GG );
    Events::Player::OnConCommand.Hook( @OnConCommand_GG );
    Events::Player::PlayerSay.Hook( @PlayerSay_GG );
    Events::Player::OnEntityDropped.Hook( @OnEntityDropped_GG );
    
    Events::Infected::OnInfectedSpawned.Hook( @OnInfectedSpawned_GG );
    
    GunGame::Player::ClearData();
    GunGame::Player::Reset();
    GunGame::Manager::Init();
}

//------------------------------------------------------------------------------------------------------------------------//

void ThePresident_OnRoundStart()
{
    HuntedDMSetup();
    GunGame::Player::Reset();
    GunGame::Manager::Init();
}

//------------------------------------------------------------------------------------------------------------------------//

void HuntedDMSetup()
{
//  for ( uint i = 0; i < arrChristmasProps.length(); i++ )
//      Engine.PrecacheFile( model, arrChristmasProps[i] );
    ThePresident::Hunted::SetDeathmatch( true );
    ThePresident.OverrideWeaponFastSwitch( true );
    ThePresident.IgnoreDefaultScoring( true );
    Engine.RunConsoleCommand( "mp_roundlimit 1" );
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnRandomItemSpawn_GG(const string &in strClassname, CBaseEntity@ pEntity)
{
    pEntity.SUB_Remove();
    return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnTerminateRound_GG(int iTeam)
{
    GunGame::Player::Reset();
    return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnEntityDropped_GG(CTerrorPlayer@ pPlayer, CBaseEntity@ pEntity)
{
    pEntity.SUB_Remove();
    return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerSpawn_GG(CTerrorPlayer@ pPlayer)
{
    if ( pPlayer is null ) return HOOK_CONTINUE;
    if ( pPlayer is null ) return HOOK_CONTINUE;
    if ( pPlayer.GetTeamNumber() == TEAM_SURVIVOR )
    {
        DropWeapons( pPlayer );
        GunGame::Player::Spawned( pPlayer.entindex() );
        GunGame::SetGlowIfLeader( pPlayer.entindex() );
        // No screen fade
        Utils.ScreenFade( pPlayer, Color( 0, 0, 255 ), 0.0f, 0.0f, fade_purge );
    }
    return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerConnected_GG(CTerrorPlayer@ pPlayer)
{
    if ( pPlayer is null ) return HOOK_CONTINUE;
    int iIndex = pPlayer.entindex();
    @gg_players[iIndex] = CGunGamePlayer(iIndex);
    return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerKilled_GG(CTerrorPlayer@ pPlayer, CTakeDamageInfo &in DamageInfo)
{
    CBaseEntity @pAttacker = DamageInfo.GetAttacker();
    const bool bIsPlayer = pAttacker.IsPlayer();
    if ( !bIsPlayer ) return HOOK_CONTINUE;
    if ( pAttacker !is null && pPlayer !is null )
        GunGame::Player::KilledPlayer( pPlayer.entindex(), pAttacker.entindex(), DamageInfo.GetDamageType() );
    return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnInfectedSpawned_GG( Infected@ pInfected )
{
    if ( pInfected !is null )
        SetNewSpeed( pInfected );
    return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnEntCreated_GG( const string &in strClassname, CBaseEntity@ pEntity )
{
    if ( Utils.StrContains( "item_ammo", pEntity.GetClassname() ) )
        pEntity.SUB_Remove();
    return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnConCommand_GG( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
    string arg1 = pArgs.Arg( 0 );
    CBasePlayer@ pBasePlayer = pPlayer.opCast();
    if ( Utils.StrEql( arg1, "drop" ) ) return HOOK_HANDLED;
    if ( Utils.StrEql( arg1, "drop_attachment" ) ) return HOOK_HANDLED;
    return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode PlayerSay_GG( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
    string arg1 = pArgs.Arg( 1 );
    CBasePlayer@ pBasePlayer = pPlayer.opCast();
    if ( Utils.StrEql( arg1, "!level" ) || Utils.StrEql( arg1, "/level" ) )
    {
        GunGame::Player::CheckStatus( pPlayer.entindex(), true );
        return HOOK_HANDLED;
    }
    return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

void DropWeapons(CTerrorPlayer@ pPlayer)
{
    pPlayer.StripEquipment( true );
}

//------------------------------------------------------------------------------------------------------------------------//

void SetNewSpeed( Infected@ pInfected )
{
    if ( pInfected is null ) return;

    // If 2012 mod is found, then use that instead.
    CNetworked@ pNetworked = Network::Get( "2012mod" );
    if ( pNetworked !is null )
    {
        if ( pNetworked.GetBool( "enabled" ) ) return;
    }

    // Randomize our animation set
    array<int> animset = {
        10,
        5,
        8,
        7
    };

    // Set our new animation set
    int iAnimSet = animset[ Math::RandomInt( 0, animset.length() - 1 ) ];
    pInfected.SetAnimationSet( iAnimSet );

    // Don't forget to make this zombie angry!
    pInfected.Enrage();
}

//------------------------------------------------------------------------------------------------------------------------//

void OnMapInit()
{
    CBaseEntity@ pEntity = null;
    PurgeItems( "item_ammo*" );
    PurgeItems( "weapon_*" );
    GunGame::Player::ClearData();
    GunGame::Player::Reset();
    GunGame::Player::RespawnWeapons();
}

//------------------------------------------------------------------------------------------------------------------------//

void PurgeItems( const string &in szEnt )
{
    CBaseEntity@ pEntity = null;
    while( true )
    {
        // Find it!
        @pEntity = FindEntityByName( null, szEnt );
        // We found nothing, just stop
        if ( pEntity is null ) break;
        // BYE!
        pEntity.SUB_Remove();
    }
}

//------------------------------------------------------------------------------------------------------------------------//

void ThePresident_OnMapStart()
{
    ThePresident_OnRoundStart();
}

//------------------------------------------------------------------------------------------------------------------------//

void OnPluginUnload()
{
    Engine.EnableCustomSettings( false );
    GunGame::Cvars::OnUnload();
    GunGame::Manager::Unload();
}

//------------------------------------------------------------------------------------------------------------------------//

void SetSomeGameRules()
{
    Engine.EnableCustomSettings( true );
    GunGame::Guns::Setup();

    // Find our console variable and put it inside our reference variable
    CASConVarRef@ infinite_collected_ammo = ConVar::Find( "sv_infinite_collected_ammo" );
    if ( infinite_collected_ammo is null ) return;
    // We don't need to remove the cheat value, as the reference convar will talk directly with the actual console variable
    infinite_collected_ammo.SetValue( "1" );
}