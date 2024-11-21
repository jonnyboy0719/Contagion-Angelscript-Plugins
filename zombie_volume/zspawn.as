
class CZombieVolumeSpawner : ScriptBase_PointEntity
{
	void SpawnVolume( CTerrorPlayer @pPlayer )
	{
		float flOffset = 1000.0f;					//Volume size offset
		Vector vPlayer = pPlayer.GetAbsOrigin();	//Player (Volume Center)
		Vector vMinVolume = Vector( vPlayer.x - flOffset, vPlayer.y - flOffset, vPlayer.z - flOffset );		//Spawn Volume - Start
		Vector vMaxVolume = Vector( vPlayer.x + flOffset, vPlayer.y + flOffset, vPlayer.z + flOffset );		//Spawn Volume - End
		ThePresident.SpawnZombiesInVolume( 25, vMinVolume, vMaxVolume, false );
	}

	void Spawn()
	{
		m_Enabled = false;
		self.SetThink( "OnThink" );
		self.SetNextThink( Globals.GetCurrentTime() + 1.0f );
	}

	void DeleteMe()
	{
		self.SUB_Remove();
	}

	void Toggle()
	{
		SetEnabled( !m_Enabled );
	}

	void SetEnabled( bool state )
	{
		m_Enabled = state;
		UpdateMusicIntensity();
	}

	void UpdateMusicIntensity()
	{
		ThePresident.SetMusicIntensity( m_Enabled ? MUSIC_COMBAT : MUSIC_ALERT );
	}

	void OnThink()
	{
		if ( !m_Enabled )
		{
			self.SetNextThink( Globals.GetCurrentTime() + 1.0 );
			return;
		}
		array<int> collector = Utils.CollectPlayers();
        if ( collector.length() > 0 )
        {
            // Go trough our collector
            CTerrorPlayer@ pTerror = null;
            for ( uint u = 0; u < collector.length(); u++ )
            {
                @pTerror = ToTerrorPlayer( collector[ u ] );
                SpawnVolume( pTerror );
            }
        }
		self.SetNextThink( Globals.GetCurrentTime() + 3.0 );
	}

	private bool m_Enabled;
}
CZombieVolumeSpawner @ZombieVolumeSpawner = null;

//------------------------------------------------------------------------------------------------------------------------//

// Make sure to call this trough ThePresident_OnRoundStart() AND ThePresident_OnMapStart(), or OnMapInit() if you use that instead of ThePresident
void InitZombieVolume()
{
	// Create it
	EntityCreator::RegisterCustomEntity( k_eCustomPointClass, "env_zvolume", "CZombieVolumeSpawner" );
	// Spawn it in the world
	CreateEntity();
}

void CreateEntity()
{
	ICustomEntity @pEnt = CustomEnts::Cast( EntityCreator::Create( "env_zvolume", Vector( 0, 0, 0 ), QAngle( 0, 0, 0 ) ) );
	@ZombieVolumeSpawner = cast<CZombieVolumeSpawner>( pEnt );
}

//------------------------------------------------------------------------------------------------------------------------//

void OnPluginInit()
{
	PluginData::SetName( "zspawn test" );
	Events::Player::PlayerSay.Hook( @OnPlayerSay );
	InitZombieVolume();
	// Max our zombies for this plugin
	ThePresident.MaxZombiesAllowed( 70 );
}

//------------------------------------------------------------------------------------------------------------------------//

void OnPluginUnload()
{
	EntityCreator::UnregisterCustomEntity( "env_zvolume", "CZombieVolumeSpawner" );
	if ( ZombieVolumeSpawner is null ) return;
	ZombieVolumeSpawner.DeleteMe();
	@ZombieVolumeSpawner = null;
}

//------------------------------------------------------------------------------------------------------------------------//

void ThePresident_OnMapStart() { InitZombieVolume(); }
void ThePresident_OnRoundStart() { InitZombieVolume(); }

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerSay( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	string arg1 = pArgs.Arg( 1 );
	if ( Utils.StrEql( arg1, "/zspawn" ) )
	{
		ZombieVolumeSpawner.Toggle();
		return HOOK_HANDLED;
	}
	return HOOK_CONTINUE;
}
