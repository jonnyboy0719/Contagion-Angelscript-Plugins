namespace RTD
{
    class CPerkMommyPlease : IRollTheDiceTypeBase
    {
        CPerkMommyPlease()
        {
            m_ID = "mommyplease";
            m_Name = "Mommy Please!";
            m_Desc = "You will lose 50% of your current HP, and if in the air,\n you will be slapped in a random direction.";
            m_Time = 3.0f;
            m_PerkType = k_eBad;
            m_NoRollEndNotify = true;
            g_rtd.RegisterItem( this );
        }

        void DoSlapDamage( CTerrorPlayer@ pPlayer )
        {
            // Slap em!
            Vector velocity = pPlayer.GetAbsVelocity();
            velocity.x += Math::RandomInt( 50, 180 ) * ((Math::RandomInt( 0, 2 ) == 1) ?  -1 : 1);
            velocity.y += Math::RandomInt( 50, 180 ) * ((Math::RandomInt( 0, 2 ) == 1) ?  -1 : 1);
            velocity.z += Math::RandomInt( 100, 200 );
            pPlayer.ApplyVelocity( velocity );

            // Take damage
            int damage = (pPlayer.GetHealth() / 2);
            CTakeDamageInfo info = CTakeDamageInfo( pPlayer, pPlayer, damage, DMG_CRUSH );
            pPlayer.TakeDamage( info );

            pPlayer.PlayWwiseSound( "SFX_ImpactBreak_Flesh", "", -1 );
        }

        void OnRollStart( CTerrorPlayer@ pPlayer )
        {
            if ( pPlayer is null ) return;
            DoSlapDamage( pPlayer );
        }
    }
}