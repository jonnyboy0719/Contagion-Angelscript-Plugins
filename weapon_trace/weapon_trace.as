class CScriptWeaponTraceTest : ScriptBase_Weapon
{
	void GetWeaponInformation( WeaponInfo& out info )
	{
		info.szResFile				= "weapon_glock";
		info.szPrintName			= "Tracer";
		info.szIconName				= "glock18c";
		info.szIconNameSB			= "glock18c_sb";
		info.szWeaponModel_V		= "models/weapons/v_sig/v_sig.mdl";
		info.szWeaponModel_W		= "models/weapons/w_models/w_sig/w_sig.mdl";
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
		self.SetClipSize( 1 );
		self.SetAmmoType( AMMO_NONE );
		self.SetAllowUnderWater( true );
		self.SetIsHeavy( false );
		self.SetAllowAttachmentDrop( false );
	}

	// Precache the files, so we don't crash the server,
	// and so that clients can download these.
	void Precache()
	{
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
		Vector vec_end = vecEyes + vec * 500;
		Utils.TraceLine( vecEyes, vec_end, MASK_SHOT, pTerrorPlayer, COLLISION_GROUP_NONE, tr );

		// Find valid looking position
		if ( tr.fraction < 1.0 )
		{
			//Chat.PrintToChat( pTerrorPlayer, "{green}We hit something!" );
			if ( tr.m_pEnt !is null )
			{
				//Chat.PrintToChat( pTerrorPlayer, "Damaged entity {green}" + tr.m_pEnt.GetClassname() + " {default}with 20 dmg!" );
				//CTakeDamageInfo info = CTakeDamageInfo( pTerrorPlayer, 20.0f, DMG_BULLET );
				//tr.m_pEnt.TakeDamage( info );
			}
			Utils.EnvExplosion( tr.endpos, 600 );
		}

		//Chat.PrintToChat( pTerrorPlayer, "tr.endpos = {gold}({green}" + tr.endpos.x + "," + tr.endpos.y + "," + tr.endpos.z + "{gold})" );

		// Set the new timer
		self.m_flNextPrimaryAttack = Globals.GetCurrentTime() + 0.1;
		self.SetWeaponIdleTime( self.m_flNextPrimaryAttack );
	}

	// This cannot be reloaded
	bool Reload(bool &in bEmpty)
	{
		return false;
	}

	void GetAnimationEvent( int &in event )
	{
	}
}

void OnPluginInit()
{
	RegisterWeapon();
}

void ThePresident_OnMapStart()
{
	RegisterWeapon();
}

void RegisterWeapon()
{
	// Register our weapon
	EntityCreator::RegisterCustomWeapon( "weapon_trace", "CScriptWeaponTraceTest" );
}
