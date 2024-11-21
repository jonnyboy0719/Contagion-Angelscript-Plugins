namespace RTD
{
	class CPerkSacrifice : IRollTheDiceTypeBase
	{
		CPerkSacrifice()
		{
			m_ID = "sacrifice";
			m_Name = "Sacrifice";
			m_Desc = "Every zombie will mark you as their new target.";
			m_Time = 3.0f;
			m_PerkType = k_eBad;
			m_NoRollEndNotify = true;
			g_rtd.RegisterItem( this );
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			// Collect all zombies
			array<int> collector = Utils.CollectInfected();

			// No zombies found? then skip
			if ( collector.length() == 0 ) return;

			// Go trough our collector, and explode all zombies
			Infected@ pInfected = null;
			for ( uint i = 0; i < collector.length(); i++ )
			{
				@pInfected = ToInfected( collector[ i ] );
				pInfected.EnrageTarget( pPlayer );
			}
		}
	}
}