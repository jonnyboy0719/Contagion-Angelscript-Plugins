class CScriptHLWeaponPython : CScriptHLWeaponBase
{
	void GetWeaponInformation( WeaponInfo& out info )
	{
		info.szResFile				= "weapon_hl_357";
		info.szPrintName			= "Python .357";
		info.szIconName				= "hl_357";
		info.szIconNameSB			= "hl_357_sb";
		info.szWeaponModel_V		= "models/hl1/weapons/v_357.mdl";
		info.szWeaponModel_W		= "models/hl1/weapons/w_357.mdl";

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
		self.SetClipSize( 6 );
		self.SetAmmoType( AMMO_REVOLVER );
		self.SetAllowUnderWater( false );
		self.SetIsHeavy( false );
		self.SetAllowAttachmentDrop( false );

		m_szCrosshair = "hl1_357_crosshair";
		m_szAmmo1 = "hl1_357_ammo";
	}

	void WeaponIdle()
	{
		if ( !self.HasWeaponIdleTimeElapsed() ) return;
		Activity act;
		switch( Math::RandomInt( 0, 3 ) )
		{
			case 0: act = ACT_VM_IDLE; break;
			case 1: act = ACT_TERROR_FIDGET; break;
			case 2: act = ACT_VM_FIDGET; break;
			case 3: act = ACT_VM_PULLPIN2; break;
		}
		self.SendWeaponAnim( act );
		self.SetWeaponIdleTime( Globals.GetCurrentTime() + Math::RandomFloat( 4.5, 7.0 ) );
	}

	void PrimaryAttack()
	{
		if ( self.m_iClip <= 0 )
		{
			self.WeaponSound( "Weapon_HL_DryFire" );
			self.m_flNextPrimaryAttack = Globals.GetCurrentTime() + 0.8;
			return;
		}
		self.m_iClip--;

		self.FireBullets();

		self.WeaponSound( "Weapon_HL_PythonFire" );
		self.SendWeaponAnim( PLAYERANIMEVENT_ATTACK_PRIMARY, ACT_VM_PRIMARYATTACK );

		self.m_flNextPrimaryAttack = Globals.GetCurrentTime() + 0.75;
		self.SetWeaponIdleTime( self.m_flNextPrimaryAttack - 0.1 );
	}

	bool Reload(bool &in bEmpty)
	{
		if ( self.GetAmmoCount() <= 0 ) return false;
		if ( self.m_iClip >= self.GetMaxClip() ) return false;
		self.WeaponSound( "Weapon_HL_PythonReload" );
		return true;
	}

	void GetAnimationEvent( int &in event )
	{
	}
}
