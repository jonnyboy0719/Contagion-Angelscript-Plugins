HookReturnCode OnPlayerDamaged( CTerrorPlayer@ pPlayer, CTakeDamageInfo &in DamageInfo )
{
    CBaseEntity @pAttacker = DamageInfo.GetAttacker();
    if ( pAttacker is null ) return HOOK_CONTINUE;
    CTerrorPlayer@ pTerror = ToTerrorPlayer( pAttacker );
    if ( pTerror is null ) return HOOK_CONTINUE;
    if ( pAttacker.entindex() == pAttacker.entindex() ) return HOOK_CONTINUE;
    if ( ThePresident.GetGameModeType() != GM_HUNTED )
    {
        if ( pAttacker.GetTeamNumber() == pTerror.GetTeamNumber() )
            OnPlayerStatsUpdated( pTerror, k_AwardFriendlyFire );
    }
    return HOOK_CONTINUE;
}