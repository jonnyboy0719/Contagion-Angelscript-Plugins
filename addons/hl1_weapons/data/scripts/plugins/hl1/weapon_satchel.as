class CScriptHLWeaponSatchel : ScriptBase_Weapon
{
	private bool m_bThrown = false;

	void GetWeaponInformation( WeaponInfo& out info )
	{
		info.szResFile				= "weapon_hl_satchel";
		info.szPrintName			= "Satchel";
		info.szIconName				= "hl1_satchel";
		info.szIconNameSB			= "hl1_satchel_sb";
		info.szWeaponModel_V		= "models/hl1/weapons/v_satchel.mdl";
		info.szWeaponModel_W		= "models/hl1/weapons/w_satchel.mdl";
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
		self.SetClipSize( 5 );
		self.SetAmmoType( AMMO_NONE );
		self.SetAllowUnderWater( true );
		self.SetIsHeavy( false );
		self.SetAllowAttachmentDrop( false );
	}

	bool IsEmpty()
	{
		return (self.m_iClip <= 0) ? true : false;
	}

	void WeaponIdle()
	{
		if ( !self.HasWeaponIdleTimeElapsed() ) return;
		Activity act;
		if ( m_bThrown )
		{
			if ( IsEmpty() )
				act = ACT_VM_FIDGET;
			else
				act = ACT_TERROR_FIDGET;
		}
		else
			act = ACT_VM_IDLE;
		self.SendWeaponAnim( act );
		self.SetWeaponIdleTime( Globals.GetCurrentTime() + Math::RandomFloat( 6.5, 7.0 ) );
	}

	void SecondaryAttack()
	{
		if ( !m_bThrown ) return;
		ThrowSatchel();
	}

	void PrimaryAttack()
	{
		if ( m_bThrown )
		{
			self.WeaponSound( "Weapon_IED_Detonate" );
			self.SendWeaponAnim( PLAYERANIMEVENT_ATTACK_PRIMARY, IsEmpty() ? ACT_VM_PRIMARYATTACK : ACT_VM_SECONDARYATTACK );
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = Globals.GetCurrentTime() + 1.0;
			self.SetWeaponIdleTime( self.m_flNextSecondaryAttack - 0.05 );
			return;
		}
		ThrowSatchel();
	}

	void Deploy()
	{
		CTerrorPlayer@ pTerrorPlayer = self.GrabOwner();
		bool bFound = false;
		// Check if we have any active satchels!
		string strClassname = "hl1_satchel";
		CBaseEntity @pEnt = FindEntityByClassname( null, strClassname );
		while( pEnt !is null )
		{
			ICustomEntity @pCustomEnt = CustomEnts::Cast( pEnt );
			CScriptSatchelThrownNPC @pGrenade = cast<CScriptSatchelThrownNPC>( pCustomEnt );
			if ( pGrenade !is null )
			{
				if ( pGrenade.OwnSatchel( pTerrorPlayer ) )
				{
					bFound = true;
					break;
				}
			}
			@pEnt = FindEntityByClassname( pEnt, strClassname );
		}
		if ( bFound )
			m_bThrown = true;
		else
			m_bThrown = false;
		// We have no ammo, and we found no satchels on the map, remove this
		if ( !m_bThrown && IsEmpty() )
			self.SUB_Remove();
	}

	Activity GetDeployActivity()
	{
		if ( m_bThrown )
		{
			if ( IsEmpty() )
				return ACT_CONTAGION_DRAW_PISTOL;
			else
				return ACT_CONTAGION_DRAW_RIFLE;
		}
		return ACT_VM_DRAW;
	}

	void ThrowSatchel()
	{
		if ( IsEmpty() ) return;

		// Grab our owner
		CTerrorPlayer@ pTerrorPlayer = self.GrabOwner();

		// Calculate position that the player is looking at.
		const Vector vecEyes = pTerrorPlayer.EyePosition();

		Vector vec;
		Globals.AngleVectors( pTerrorPlayer.EyeAngles(), vec );

		CGameTrace tr;
		Vector vec_end = vecEyes + vec * 16;

		ICustomEntity @pEnt = CustomEnts::Cast( EntityCreator::Create( "hl1_satchel", vec_end, pTerrorPlayer.EyeAngles() ) );
		CScriptSatchelThrownNPC @pGrenade = cast<CScriptSatchelThrownNPC>( pEnt );
		if ( pGrenade is null ) return;
		Vector	vecThrow;
		Globals.AngleVectors( pTerrorPlayer.EyeAngles(), vecThrow );
		pGrenade.Setup( pTerrorPlayer, vecThrow * 400 );

		self.m_iClip--;
		m_bThrown = true;

		self.SendWeaponAnim( GetDeployActivity() );

		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = Globals.GetCurrentTime() + 1.0;
		self.SetWeaponIdleTime( self.m_flNextSecondaryAttack - 0.05 );
	}

	void Detonate()
	{
		CTerrorPlayer@ pTerrorPlayer = self.GrabOwner();
		m_bThrown = false;
		string strClassname = "hl1_satchel";
		CBaseEntity @pEnt = FindEntityByClassname( null, strClassname );
		while( pEnt !is null )
		{
			ICustomEntity @pCustomEnt = CustomEnts::Cast( pEnt );
			CScriptSatchelThrownNPC @pGrenade = cast<CScriptSatchelThrownNPC>( pCustomEnt );
			if ( pGrenade !is null )
			{
				if ( pGrenade.OwnSatchel( pTerrorPlayer ) )
					pGrenade.Explode();
			}
			else
				pEnt.SUB_Remove();
			@pEnt = FindEntityByClassname( pEnt, strClassname );
		}
		// We have no ammo left, delete this
		if ( self.m_iClip <= 0 )
		{
			self.SwitchAwayFromThis();
			self.SUB_Remove();
		}
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = Globals.GetCurrentTime() + 1.0;
		self.SetWeaponIdleTime( self.m_flNextSecondaryAttack - 0.05 );
	}

	// This cannot be reloaded
	bool Reload( bool &in bEmpty )
	{
		return false;
	}

	void GetAnimationEvent( int &in event )
	{
		if ( event == 80 )
			Detonate();
	}
}