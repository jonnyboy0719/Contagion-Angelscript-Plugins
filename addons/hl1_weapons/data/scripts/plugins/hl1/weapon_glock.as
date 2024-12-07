class CScriptHLWeaponGlock : CScriptHLWeaponBase
{
	void GetWeaponInformation( WeaponInfo& out info )
	{
		info.szResFile				= "weapon_hl_glock";
		info.szPrintName			= "Glock";
		info.szIconName				= "hl_glock";
		info.szIconNameSB			= "hl_glock_sb";
		info.szWeaponModel_V		= "models/hl1/weapons/v_glock.mdl";
		info.szWeaponModel_W		= "models/hl1/weapons/w_glock.mdl";

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
		self.SetClipSize( 17 );
		self.SetAmmoType( AMMO_PISTOL );
		self.SetAllowUnderWater( true );
		self.SetIsHeavy( false );
		self.SetAllowAttachmentDrop( false );

		m_szCrosshair = "hl1_glock_crosshair";
		m_szAmmo1 = "hl1_glock_ammo";
	}

	void SecondaryAttack()
	{
		GlockFire( 0.2 );
	}

	void PrimaryAttack()
	{
		GlockFire( 0.3 );
	}

	void WeaponIdle()
	{
		if ( !self.HasWeaponIdleTimeElapsed() ) return;
		Activity act;
		switch( Math::RandomInt( 0, 2 ) )
		{
			case 0: act = ACT_VM_IDLE; break;
			case 1: act = ACT_TERROR_FIDGET; break;
			case 2: act = ACT_VM_FIDGET; break;
		}
		self.SendWeaponAnim( act );
		self.SetWeaponIdleTime( Globals.GetCurrentTime() + Math::RandomFloat( 4.5, 7.0 ) );
	}

	void GlockFire( float flCycleTime )
	{
		if ( self.m_iClip <= 0 )
		{
			self.WeaponSound( "Weapon_HL_DryFire" );
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = Globals.GetCurrentTime() + 0.15;
			return;
		}
		self.m_iClip--;

		self.FireBullets();

		self.WeaponSound( "Weapon_HL_GlockFire" );
		self.SendWeaponAnim( PLAYERANIMEVENT_ATTACK_PRIMARY, ( self.m_iClip <= 0 ) ? ACT_VM_PRIMARYATTACK_LAST : ACT_VM_PRIMARYATTACK );

		float flNextFire = Globals.GetCurrentTime() + flCycleTime;
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = flNextFire;
		self.SetWeaponIdleTime( self.m_flNextPrimaryAttack - 0.1 );
	}

	bool Reload(bool &in bEmpty)
	{
		if ( self.GetAmmoCount() <= 0 ) return false;
		if ( self.m_iClip >= self.GetMaxClip() ) return false;
		self.WeaponSound( "Weapon_HL_GlockReload" );
		return true;
	}

	void GetAnimationEvent( int &in event )
	{
	}
}
