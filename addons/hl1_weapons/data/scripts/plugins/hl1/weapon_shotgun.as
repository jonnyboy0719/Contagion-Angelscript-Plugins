class CScriptHLWeaponShotgun : CScriptHLWeaponBase
{
	void GetWeaponInformation( WeaponInfo& out info )
	{
		info.szResFile				= "weapon_hl_shotgun";
		info.szPrintName			= "Shotgun";
		info.szIconName				= "hl_shotgun";
		info.szIconNameSB			= "hl_shotgun_sb";
		info.szWeaponModel_V		= "models/hl1/weapons/v_shotgun.mdl";
		info.szWeaponModel_W		= "models/hl1/weapons/w_shotgun.mdl";

		info.szMuzzleFlash_V		= "weapon_muzzle_flash_pistol_FP";
		info.szMuzzleFlash_W		= "weapon_muzzle_flash_pistol";
		info.szEjectBrass			= "weapon_shell_casing_9mm";

		info.szSndMelee				= "Weapon_M1911_MeleeMiss";
		info.szSndMeleeHit			= "Weapon_M1911_MeleeHit";
		info.szSndMeleeHitWorld		= "Weapon_M1911_MeleeHitWorld";
	}

	void Spawn()
	{
		self.SetMeleeDamage( 50 );
		self.SetClipSize( 6 );
		self.SetAmmoType( AMMO_SHOTGUN );
		self.SetAllowUnderWater( false );
		self.SetIsHeavy( true );
		self.SetAllowAttachmentDrop( false );

		m_szCrosshair = "hl1_shotgun_crosshair";
		m_szAmmo1 = "hl1_shotgun_ammo";
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
		if ( self.m_iClip < 2 )
		{
			self.WeaponSound( "Weapon_HL_DryFire" );
			self.m_flNextPrimaryAttack = Globals.GetCurrentTime() + 0.15;
			return;
		}
		self.m_iClip -= 2;

		self.FireBullets();
		self.FireBullets();

		self.WeaponSound( "Weapon_HL_ShotgunFireAlt" );
		self.SendWeaponAnim( PLAYERANIMEVENT_ATTACK_PRIMARY, ACT_VM_SECONDARYATTACK );

		self.m_flNextSecondaryAttack = Globals.GetCurrentTime() + 2.0;
		self.SetWeaponIdleTime( self.m_flNextSecondaryAttack - 0.05 );
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

		self.WeaponSound( "Weapon_HL_ShotgunFire" );
		self.SendWeaponAnim( PLAYERANIMEVENT_ATTACK_PRIMARY, ACT_VM_PRIMARYATTACK );

		self.m_flNextPrimaryAttack = Globals.GetCurrentTime() + 0.1;
		self.SetWeaponIdleTime( self.m_flNextPrimaryAttack - 0.05 );
	}

	bool Reload(bool &in bEmpty)
	{
		if ( self.GetAmmoCount() <= 0 ) return false;
		if ( self.m_iClip >= self.GetMaxClip() ) return false;
		self.WeaponSound( "Weapon_HL_ShotgunReload" );
		return true;
	}

	void GetAnimationEvent( int &in event )
	{
	}
}
