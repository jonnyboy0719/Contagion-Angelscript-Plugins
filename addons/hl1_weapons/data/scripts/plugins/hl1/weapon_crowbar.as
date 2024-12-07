class CScriptHLWeaponCrowbar : ScriptBase_Weapon
{
	private int m_iSwing = 0;

	void GetWeaponInformation( WeaponInfo& out info )
	{
		info.szResFile				= "weapon_hl_crowbar";
		info.szPrintName			= "Crowbar";
		info.szIconName				= "hl1_crowbar";
		info.szIconNameSB			= "hl1_crowbar_sb";
		info.szWeaponModel_V		= "models/hl1/weapons/v_crowbar.mdl";
		info.szWeaponModel_W		= "models/hl1/weapons/w_crowbar.mdl";
		// Particles
		info.szMuzzleFlash_V		= "weapon_muzzle_flash_pistol_FP";
		info.szMuzzleFlash_W		= "weapon_muzzle_flash_pistol";
		info.szEjectBrass			= "weapon_shell_casing_9mm";
		// Melee sound events
		info.szSndMelee				= "Weapon_M1911_MeleeMiss";
		info.szSndMeleeHit			= "Weapon_M1911_MeleeHit";
		info.szSndMeleeHitWorld		= "Weapon_M1911_MeleeHitWorld";
	}

	void Spawn()
	{
		self.SetMeleeDamage( 25 );
		self.SetClipSize( 0 );
		self.SetAmmoType( AMMO_NONE );
		self.SetAllowUnderWater( true );
		self.SetIsHeavy( false );
		self.SetAllowAttachmentDrop( false );
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
		self.SetWeaponIdleTime( Globals.GetCurrentTime() + Math::RandomFloat( 6.5, 7.0 ) );
	}

	void SecondaryAttack()
	{
	}

	Activity GetCrowbarSwingAnim( bool bHit )
	{
		Activity act;
		switch( ((m_iSwing++) % 2) + 1 )
		{
			case 0: act = bHit ? ACT_VM_MELEE_HIT_V1 : ACT_VM_MELEE_START_V1; break;
			case 1: act = bHit ? ACT_VM_MELEE_HIT_V2 : ACT_VM_MELEE_START_V2; break;
			case 2: act = bHit ? ACT_VM_MELEE_HIT_V3 : ACT_VM_MELEE_START_V3; break;
		}
		return act;
	}

	bool HitWorld( CBaseEntity @pHit )
	{
		if ( pHit.IsPlayer() ) return false;
		string szClassname = pHit.GetClassname();
		if ( Utils.StrEql( "worldspawn", szClassname ) ) return true;
		return false;
	}

	// Override PrimaryAttack with our own function
	void PrimaryAttack()
	{
		// Grab our owner
		CTerrorPlayer@ pTerrorPlayer = self.GrabOwner();

		// Calculate position that the player is looking at.
		const Vector vecEyes = pTerrorPlayer.EyePosition();

		Vector vec;
		Globals.AngleVectors( pTerrorPlayer.EyeAngles(), vec );

		CGameTrace tr;
		Vector vec_end = vecEyes + vec * 65;
		Utils.TraceLine( vecEyes, vec_end, MASK_SOLID, pTerrorPlayer, COLLISION_GROUP_NONE, tr );

		bool bHitSomething = false;
		CBaseEntity @pHit = null;

		if ( tr.fraction < 1.0 )
		{
			if ( tr.m_pEnt !is null )
				@pHit = tr.m_pEnt;
		}

		if ( pHit !is null )
			bHitSomething = true;

		// Play our animation
		self.SendWeaponAnim( GetCrowbarSwingAnim( bHitSomething ) );

		// Play default swing sound if we hit nothing
		if ( !bHitSomething )
			self.WeaponSound( "Weapon_HL_CrowbarSwing" );
		else
		{
			// If we hit the world
			if ( HitWorld( pHit ) )
				self.WeaponSound( "Weapon_HL_CrowbarHitWorld" );
			else
				self.WeaponSound( "Weapon_HL_CrowbarHitFlesh" );

			// Damage said entity
			Utils.ClearMultiDamage();
			CTakeDamageInfo info = CTakeDamageInfo( pTerrorPlayer, 55.0f, DMG_CLUB );
			//pHit.TakeDamage( info );
			Utils.TraceAttack( pHit, info, vecEyes, tr );
			Utils.ApplyMultiDamage();
		}

		// Set the new timer
		float flSwingDelay = bHitSomething ? 0.2f : 0.5f;
		self.m_flNextPrimaryAttack = Globals.GetCurrentTime() + flSwingDelay;
		self.SetWeaponIdleTime( self.m_flNextPrimaryAttack - 0.05 );
	}

	// This cannot be reloaded
	bool Reload( bool &in bEmpty )
	{
		return false;
	}

	void GetAnimationEvent( int &in event )
	{
	}
}