namespace GunGame
{
    namespace Manager
    {
        class CManagerEntity : ScriptBase_PointEntity
        {
            void Spawn()
            {
                self.SetThink( "GunGameThink" );
                self.SetNextThink( Globals.GetCurrentTime() + 1.0f );
            }
            
            void GunGameThink()
            {
                GunGame::CheckWinner();
                array<int> collector = Utils.CollectPlayers();
                if ( collector.length() > 0 )
                {
                    // Go trough our collector
                    CTerrorPlayer@ pTerror = null;
                    for ( uint i = 0; i < collector.length(); i++ )
                    {
                        @pTerror = ToTerrorPlayer( collector[ i ] );
                        if ( pTerror is null ) continue;
                        // If it's a grenade, make sure we always have a grenade
                        CGunGamePlayer @pPlayer = @gg_players[ pTerror.entindex() ];
                        if ( pPlayer is null ) continue;
                        DrawHUDInfo( pTerror, pPlayer );
                        // Our weapon slot is empty?
                        CBaseEntity@ pEntity = pTerror.GetWeaponFromSlot( 0 );
                        if ( pEntity is null )
                            pPlayer.GiveWeapons();
                    }
                }
                self.SetNextThink( Globals.GetCurrentTime() + 0.1 );
            }
        }
        CManagerEntity @GunGameManager = null;
        
        void Init()
        {
            // Create it
            EntityCreator::RegisterCustomEntity( k_eCustomPointClass, "gungame_manager", "GunGame::Manager::CManagerEntity" );
            // Spawn it in the world
            CreateEntity( Vector( 0, 0, 0 ) );
        }
        
        void Unload()
        {
            EntityCreator::UnregisterCustomEntity( "gungame_manager", "GunGame::Manager::CManagerEntity" );
        }
        
        void CreateEntity( const Vector &in voxOrigin )
        {
            CBaseEntity @pFind = FindEntityByClassname( "gungame_manager" );
            if ( pFind !is null ) return;
        
            ICustomEntity @pEnt = CustomEnts::Cast( EntityCreator::Create( "gungame_manager", voxOrigin, QAngle( 0, 0, 0 ) ) );
            @GunGameManager = cast<GunGame::Manager::CManagerEntity>( pEnt );
        }
    }
}