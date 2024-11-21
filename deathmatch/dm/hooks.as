namespace DeathMatch
{
	namespace Hooks
	{
		void Init()
		{
			// The following hooks are registered under respawn.as
			// - ThePresident::OnNoSurvivorsRemaining
			// - Player::OnPlayerKilledPost
			Events::ThePresident::OnRandomItemSpawn.Hook( @OnRandomItemSpawn_DM );
			Events::Entities::OnEntityCreation.Hook( @OnEntCreated_DM );
			Events::Player::OnEntityDropped.Hook( @OnEntityDropped_DM );
			Events::Player::OnConCommand.Hook( @OnConCommand_DM );
			Events::Player::PlayerSay.Hook( @PlayerSay_DM );
			Events::Player::OnPlayerConnected.Hook( @OnPlayerConnected_DM );
			Events::Player::OnPlayerSpawn.Hook( @OnPlayerSpawn_DM );
			Events::Player::OnPlayerKilled.Hook( @OnPlayerKilled_DM );
			Events::Infected::OnInfectedKilled.Hook( @OnInfectedKilled_DM );
		}

		//------------------------------------------------------------------------------------------------------------------------//

		HookReturnCode OnRandomItemSpawn_DM( const string &in strClassname, CBaseEntity@ pEntity )
		{
			pEntity.SUB_Remove();
			return HOOK_CONTINUE;
		}

		//------------------------------------------------------------------------------------------------------------------------//

		HookReturnCode OnEntCreated_DM( const string &in strClassname, CBaseEntity@ pEntity )
		{
			if ( Utils.StrContains( "item_ammo", pEntity.GetClassname() ) )
				pEntity.SUB_Remove();
			return HOOK_CONTINUE;
		}

		//------------------------------------------------------------------------------------------------------------------------//

		HookReturnCode OnEntityDropped_DM( CTerrorPlayer@ pPlayer, CBaseEntity@ pEntity )
		{
			pEntity.SUB_Remove();
			return HOOK_CONTINUE;
		}

		//------------------------------------------------------------------------------------------------------------------------//

		HookReturnCode OnConCommand_DM( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
		{
			string arg1 = pArgs.Arg( 0 );
			if ( Utils.StrEql( arg1, "drop" ) ) return HOOK_HANDLED;
			if ( Utils.StrEql( arg1, "drop_attachment" ) ) return HOOK_HANDLED;
			return HOOK_CONTINUE;
		}

		//------------------------------------------------------------------------------------------------------------------------//

		HookReturnCode PlayerSay_DM( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
		{
			string arg1 = pArgs.Arg( 1 );
			if ( Utils.StrEql( arg1, "!menu" ) || Utils.StrEql( arg1, "!guns" ) )
			{
				DeathMatch::GunMenu::Draw( pPlayer );
				return HOOK_HANDLED;
			}
			return HOOK_CONTINUE;
		}

		//------------------------------------------------------------------------------------------------------------------------//

		HookReturnCode OnPlayerConnected_DM( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return HOOK_CONTINUE;
			DeathMatch::Respawn::Connected( pPlayer );
			return HOOK_CONTINUE;
		}

		//------------------------------------------------------------------------------------------------------------------------//

		HookReturnCode OnPlayerSpawn_DM( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return HOOK_CONTINUE;
			if ( pPlayer.GetTeamNumber() == TEAM_SURVIVORS )
			{
				if ( DeathMatch::Cvars::GunMenuOnSpawn.GetBool() )
					DeathMatch::GunMenu::DrawOnFirstSpawn( pPlayer );
				DeathMatch::Respawn::Spawned( pPlayer );
			}
			return HOOK_CONTINUE;
		}

		//------------------------------------------------------------------------------------------------------------------------//

		HookReturnCode OnPlayerKilled_DM( CTerrorPlayer@ pPlayer, CTakeDamageInfo &in DamageInfo )
		{
			if ( pPlayer is null ) return HOOK_CONTINUE;
			CTerrorPlayer @pAttacker = ToTerrorPlayer( DamageInfo.GetAttacker() );
			if ( pAttacker is null ) return HOOK_CONTINUE;
			DeathMatch::ScoreManager::CheckKiller( pAttacker );
			// Increase HP
			int iHealthMax = pAttacker.GetMaxHealth();
			int iHealth = pAttacker.GetHealth() + 25;
			pAttacker.SetHealth( Math::clamp( iHealth, 0, iHealthMax ) );
			return HOOK_CONTINUE;
		}

		//------------------------------------------------------------------------------------------------------------------------//

		HookReturnCode OnInfectedKilled_DM( Infected@ pInfected, CTakeDamageInfo &in DamageInfo )
		{
			if ( pInfected is null ) return HOOK_CONTINUE;
			CTerrorPlayer @pAttacker = ToTerrorPlayer( DamageInfo.GetAttacker() );
			if ( pAttacker is null ) return HOOK_CONTINUE;
			DeathMatch::ScoreManager::CheckKiller( pAttacker );
			return HOOK_CONTINUE;
		}

		//------------------------------------------------------------------------------------------------------------------------//

	}
}