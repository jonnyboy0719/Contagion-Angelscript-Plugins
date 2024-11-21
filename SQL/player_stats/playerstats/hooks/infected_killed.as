bool HasDMGFlag( int flags, int flag )
{
    return ((flags&flag) == flag);
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnInfectedKilled( Infected@ pInfected, CTakeDamageInfo &in DamageInfo )
{
    CBaseEntity @pAttacker = DamageInfo.GetAttacker();
    if ( pAttacker is null ) return HOOK_CONTINUE;
    CTerrorPlayer@ pTerror = ToTerrorPlayer( pAttacker );
    if ( pTerror is null ) return HOOK_CONTINUE;
    
    // Zombie is dead
    OnPlayerStatsUpdated( pTerror, k_InfectedKilled );
    
    // Check for ZombieID
    if ( pInfected.LastHitGroup() == HITGROUP_HEAD )
        OnPlayerStatsUpdated( pTerror, k_InfectedHeadShot );
    
    int dmgFlags = DamageInfo.GetDamageType();
    if ( HasDMGFlag( dmgFlags, DMG_CLUB ) || HasDMGFlag( dmgFlags, DMG_SLASH ) )
        OnPlayerStatsUpdated( pTerror, k_KillsMelee );
    
    // Check the ID
    switch( pInfected.GetZombieID() )
    {
        case ZID_RIOT: OnPlayerStatsUpdated( pTerror, k_KillsRiots ); break;
        case ZID_DOCTOR: OnPlayerStatsUpdated( pTerror, k_KillsDoctors ); break;
        case ZID_LOOTER: OnPlayerStatsUpdated( pTerror, k_KillsLooters ); break;
        case ZID_BOSS_CHARGER: OnPlayerStatsUpdated( pTerror, k_KillsChargers ); break;
    }
    
    return HOOK_CONTINUE;
}