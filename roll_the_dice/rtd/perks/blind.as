namespace RTD
{
	class CPerkBlind : IRollTheDiceTypeBase
	{
		CPerkBlind()
		{
			m_ID = "blind";
			m_Name = "Blindness";
			m_Desc = "Will blind the you for 15 second.";
			m_Time = 15.0f;
			m_PerkType = k_eBad;
			g_rtd.RegisterItem( this );
		}

		void DoFadeMsg( CTerrorPlayer @pPlayer, bool bBegin )
		{
			UserMessage.Begin( pPlayer, "Fade" );
				UserMessage.WriteShort( 1536 );
				UserMessage.WriteShort( 1536 );
				UserMessage.WriteShort( bBegin ? (0x0002 | 0x0008) : (0x0001 | 0x0010) );
				UserMessage.WriteByte( 0 );
				UserMessage.WriteByte( 0 );
				UserMessage.WriteByte( 0 );
				UserMessage.WriteByte( bBegin ? 255 : 0 );
			UserMessage.End();
		}

		void OnRollEnd( CTerrorPlayer @pPlayer, PerkState ePerk )
		{
			if ( pPlayer is null ) return;
			DoFadeMsg( pPlayer, false );
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			DoFadeMsg( pPlayer, true );
		}
	}
}