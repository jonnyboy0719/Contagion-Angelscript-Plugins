class CScriptHLWeaponTripmine : ScriptBase_Weapon
{
	void GetWeaponInformation( WeaponInfo& out info )
	{
		info.szResFile				= "weapon_hl_tripmine";
		info.szPrintName			= "Tripmine";
		info.szIconName				= "hl1_tripmine";
		info.szIconNameSB			= "hl1_tripmine_sb";
		info.szWeaponModel_V		= "models/hl1/weapons/v_tripmine.mdl";
		info.szWeaponModel_W		= "models/hl1/weapons/w_tripmine.mdl";
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

	void WeaponIdle()
	{
		if ( !self.HasWeaponIdleTimeElapsed() ) return;
		Activity act;
		switch( Math::RandomInt( 0, 3 ) )
		{
			case 0: act = ACT_VM_IDLE; break;
			case 1: act = ACT_TERROR_FIDGET; break;
			case 2: act = ACT_VM_FIDGET; break;
			case 3: act = ACT_VM_LOB; break;
		}
		self.SendWeaponAnim( act );
		self.SetWeaponIdleTime( Globals.GetCurrentTime() + Math::RandomFloat( 6.5, 7.0 ) );
	}

	void SecondaryAttack()
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
		Vector vec_end = vecEyes + vec * 128;
		Utils.TraceLine( vecEyes, vec_end, MASK_SOLID, pTerrorPlayer, COLLISION_GROUP_NONE, tr );

		// Find valid looking position
		if ( tr.fraction < 1.0 )
		{
			//Chat.PrintToChat( pTerrorPlayer, "{green}We hit something!" );
			if ( tr.m_pEnt !is null )
			{
				QAngle qAngle;
				Globals.VectorAngles( tr.TracePlaneNormal(), qAngle );
				qAngle.x += 90;
				ICustomEntity @pEnt = CustomEnts::Cast( EntityCreator::Create( "hl1_tripmine", tr.endpos + tr.TracePlaneNormal() * 3, qAngle ) );
				CScriptTripMineNPC @pTripmine = cast<CScriptTripMineNPC>( pEnt );
				if ( pTripmine !is null )
				{
					// This is the guy who placed it.
					pTripmine.SetTripmineOwner( pTerrorPlayer );
					self.SwitchAwayFromThis();
					self.SUB_Remove();
					return;
				}
			}
		}

		// Set the new timer
		self.m_flNextPrimaryAttack = Globals.GetCurrentTime() + 0.8f;
		self.SetWeaponIdleTime( self.m_flNextPrimaryAttack );
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