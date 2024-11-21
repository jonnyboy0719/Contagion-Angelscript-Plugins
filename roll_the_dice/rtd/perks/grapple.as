namespace RTD
{
	namespace Grapple
	{
		void DoKill( int client )
		{
			CTerrorPlayer @pPlayer = ToTerrorPlayer( client );
			if ( pPlayer is null ) return;
			if ( !pPlayer.IsAlive() ) return;
			pPlayer.TakeDamage( CTakeDamageInfo( pPlayer, pPlayer.GetHealth(), DMG_SLASH ) );
		}
	}

	class CPerkGrapple : IRollTheDiceTypeBase
	{
		CPerkGrapple()
		{
			m_ID = "grapple";
			m_Name = "Ghost Grapple";
			m_Desc = "You will be forcefully grappled.\nThere is a 50% chance of you dying.";
			m_Time = 5.0f;
			m_PerkType = k_eBad;
			m_NoRollEndNotify = true;
			g_rtd.RegisterItem( this );
		}

		void OnFireGameEvent( ASGameEvent &in event )
		{
			if ( Utils.StrEql( event.GetName(), "player_grapple" ) )
			{
				// Make sure this is a forced grapple
				if ( !event.GetBool( "forced" ) ) return;
				bool bDoKillPlayer = ( Math::RandomInt( 0, 1 ) == 1 );
				CTerrorPlayer @pPlayer = FromUserID( event.GetInt( "userid" ) );
				// 50% chance of killing the player!
				if ( pPlayer is null ) return;
				if ( bDoKillPlayer )
				{
					pPlayer.Vocalize( k_eVoiceTurning );
					Schedule::Task( 2.5, pPlayer.entindex(), RTD::Grapple::DoKill );
				}
				else
					pPlayer.Vocalize( k_eVoicePain );
			}
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			// No zombie is grappling us, but force being grappled anyway!
			pPlayer.ForceGrapple( null );
		}
	}
}