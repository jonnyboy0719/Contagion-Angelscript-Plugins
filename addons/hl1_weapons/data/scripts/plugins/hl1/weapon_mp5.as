class CScriptHLWeaponMP5 : CScriptHLWeaponBase
{
	void GetWeaponInformation( WeaponInfo& out info )
	{
		info.szResFile				= "weapon_hl_mp5";
		info.szPrintName			= "MP5";
		info.szIconName				= "hl_mp5";
		info.szIconNameSB			= "hl_mp5_sb";
		info.szWeaponModel_V		= "models/hl1/weapons/v_mp5.mdl";
		info.szWeaponModel_W		= "models/hl1/weapons/w_mp5.mdl";

		info.szMuzzleFlash_V		= "weapon_muzzle_flash_pistol_FP";
		info.szMuzzleFlash_W		= "weapon_muzzle_flash_pistol";
		info.szEjectBrass			= "weapon_shell_casing_9mm";

		info.szSndMelee				= "Weapon_M1911_MeleeMiss";
		info.szSndMeleeHit			= "Weapon_M1911_MeleeHit";
		info.szSndMeleeHitWorld		= "Weapon_M1911_MeleeHitWorld";
	}

	void Spawn()
	{
		self.SetMeleeDamage( 25 );
		self.SetClipSize( 30 );
		self.SetAmmoType( AMMO_PISTOL );
		self.SetAllowUnderWater( false );
		self.SetIsHeavy( false );
		self.SetAllowAttachmentDrop( false );

		m_iClip2 = 5;
		m_szCrosshair = "hl1_mp5_crosshair";
		m_szAmmo1 = "hl1_mp5_ammo";
		m_szAmmo2 = "hl1_mp5_ammo2";
	}

	void WeaponIdle()
	{
		if ( !self.HasWeaponIdleTimeElapsed() ) return;
		Activity act;
		switch( Math::RandomInt( 0, 1 ) )
		{
			case 0: act = ACT_VM_IDLE; break;
			case 1: act = ACT_VM_FIDGET; break;
		}
		self.SendWeaponAnim( act );
		self.SetWeaponIdleTime( Globals.GetCurrentTime() + Math::RandomFloat( 4.5, 7.0 ) );
	}

	void SecondaryAttack()
	{
		// Launch Grenade
		if ( m_iClip2 <= 0 )
		{
			self.WeaponSound( "Weapon_HL_DryFire" );
			self.m_flNextSecondaryAttack = Globals.GetCurrentTime() + 0.15;
			return;
		}
		m_iClip2--;

		self.WeaponSound( "Weapon_HL_MP5FireAlt" );
		self.SendWeaponAnim( PLAYERANIMEVENT_ATTACK_PRIMARY, ACT_VM_SECONDARYATTACK );

		LaunchGrenade();

		self.m_flNextSecondaryAttack = Globals.GetCurrentTime() + 1.0;
		self.SetWeaponIdleTime( self.m_flNextSecondaryAttack - 0.05 );
	}

	void LaunchGrenade()
	{
		// Grab our owner
		CTerrorPlayer@ pTerrorPlayer = self.GrabOwner();

		// Calculate position that the player is looking at.
		const Vector vecEyes = pTerrorPlayer.EyePosition();

		Vector vec;
		Globals.AngleVectors( pTerrorPlayer.EyeAngles(), vec );

		CGameTrace tr;
		Vector vec_end = vecEyes + vec * 16;

		ICustomEntity @pEnt = CustomEnts::Cast( EntityCreator::Create( "hl1_glauncher", vec_end, pTerrorPlayer.EyeAngles() ) );
		CScriptGrenadeLaunchedNPC @pGrenade = cast<CScriptGrenadeLaunchedNPC>( pEnt );
		if ( pGrenade is null ) return;
		Vector	vecThrow;
		Globals.AngleVectors( pTerrorPlayer.EyeAngles(), vecThrow );
		pGrenade.Setup( pTerrorPlayer, vecThrow * 800 );
	}

	void PrimaryAttack()
	{
		if ( self.m_iClip <= 0 )
		{
			self.WeaponSound( "Weapon_HL_DryFire" );
			self.m_flNextPrimaryAttack = Globals.GetCurrentTime() + 0.15;
			return;
		}
		self.m_iClip--;

		self.FireBullets();

		self.WeaponSound( "Weapon_HL_MP5Fire" );
		self.SendWeaponAnim( PLAYERANIMEVENT_ATTACK_PRIMARY, ACT_VM_PRIMARYATTACK );

		self.m_flNextPrimaryAttack = Globals.GetCurrentTime() + 0.1;
		self.SetWeaponIdleTime( self.m_flNextPrimaryAttack - 0.05 );
	}

	bool Reload(bool &in bEmpty)
	{
		if ( self.GetAmmoCount() <= 0 ) return false;
		if ( self.m_iClip >= self.GetMaxClip() ) return false;
		self.WeaponSound( "Weapon_HL_MP5Reload" );
		return true;
	}

	void GetAnimationEvent( int &in event )
	{
	}
}
