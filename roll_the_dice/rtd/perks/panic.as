namespace RTD
{
    class CPerkPanic : IRollTheDiceTypeBase
    {
        CPerkPanic()
        {
            m_ID = "panic";
            m_Name = "Panic!";
            m_Desc = "All your equipment will be thrown away.";
            m_Time = 3.0f;
            m_PerkType = k_eBad;
            m_NoRollEndNotify = true;
            g_rtd.RegisterItem( this );
        }

        void DoPanicAttack( CTerrorPlayer@ pPlayer )
        {
			// Drop all our weapons
			for ( int slot = 1; slot <= 4; slot++ )
				pPlayer.DropWeapon( slot, true );
			pPlayer.DropUnusedAmmo();
        }

        void OnRollStart( CTerrorPlayer@ pPlayer )
        {
            if ( pPlayer is null ) return;
            DoPanicAttack( pPlayer );
        }
    }
}