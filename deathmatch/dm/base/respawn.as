namespace DeathMatch
{
	namespace Respawn
	{
		array<float> _respawn_protection;

		void OnInit()
		{
			Events::ThePresident::OnNoSurvivorsRemaining.Hook( @OnNoSurvivorsRemaining_Respawn );
			_respawn_protection.resize( Globals.GetMaxClients() + 1 );	
		}

		void OnThink()
		{
			for ( uint i = 0; i < _respawn_protection.length(); i++ )
			{
				CTerrorPlayer @pTerror = ToTerrorPlayer(i);
				if ( pTerror is null ) continue;
				float flProtection = _respawn_protection[i];
				float timeleft = flProtection - Globals.GetCurrentTime();
				if ( timeleft < 0 )
				{
					if ( flProtection != -1 )
					{
						_respawn_protection[i] = -1;
						pTerror.SetGodMode( false );
						pTerror.SetRenderFX( kRenderFxNone );
						pTerror.SetRenderMode( kRenderNormal );
						pTerror.SetRenderColor( 255, 255, 255, 255 );
						Chat.PrintToChat( pTerror, "{gold}[{green}DM{gold}]{white} You are no longer spawn protected." );
					}
				}
			}
		}

		bool IsProtected( float flProtection )
		{
			if ( Globals.GetCurrentTime() > flProtection ) return false;
			return true;
		}

		void Connected( CTerrorPlayer@ pPlayer )
		{
			_respawn_protection[pPlayer.entindex()] = 0.0f;
		}

		void Spawned( CTerrorPlayer@ pPlayer )
		{
			_respawn_protection[pPlayer.entindex()] = Globals.GetCurrentTime() + DeathMatch::Cvars::GetProtectionTime.GetFloat();
			pPlayer.SetRenderFX( kRenderFxDistort );
			pPlayer.SetRenderMode( kRenderTransAdd );
			pPlayer.SetRenderColor( 0, 255, 0, 120 );
			pPlayer.SetGodMode( true );
			Chat.PrintToChat( pPlayer, "{gold}[{green}DM{gold}]{white} You will be spawn protected for {lightgreen}" + DeathMatch::Cvars::GetProtectionTime.GetFloat() + "{default} seconds." );
		}

		HookReturnCode OnNoSurvivorsRemaining_Respawn( int iCandidate )
		{
			// no game over
			return HOOK_HANDLED;
		}
	}
}