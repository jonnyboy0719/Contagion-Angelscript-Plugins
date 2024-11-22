void OnPluginInit()
{
	PluginData::SetVersion("1.0");
	PluginData::SetAuthor("Chicken Panic Inc.");
	PluginData::SetName("machine gun placement");
	Events::Player::PlayerSay.Hook(@OnPlayerSay);
}

HookReturnCode OnPlayerSay(CTerrorPlayer@ pPlayer, CASCommand@ pArgs)
{
	if (pPlayer is null || pArgs is null) return HOOK_HANDLED;
	string Arg = pArgs.Arg(1);

	if( Utils.StrContains( "!mg", Arg ) )
	{
		// Calculate position that the player is looking at.
		const Vector vecEyes = pPlayer.EyePosition();

		Vector vec;
		Globals.AngleVectors( pPlayer.EyeAngles(), vec );

		CGameTrace tr;
		Vector vec_end = vecEyes + vec * 500;
		Utils.TraceLine( vecEyes, vec_end, MASK_SHOT, pPlayer, COLLISION_GROUP_NONE, tr );

		Vector EmitPos = tr.endpos;
		QAngle EmitAng = pPlayer.EyeAngles();

		// Reset these values to 0, we only want to keep y angles
		EmitAng.x = 0;
		EmitAng.z = 0;

		CreateMountedGun( EmitPos, EmitAng );

		return HOOK_HANDLED;
	}
	return HOOK_CONTINUE;
}

void CreateMountedGun( const Vector &in vSpawnPos, const QAngle &in qAngles )
{
	CEntityData@ pData = EntityCreator::EntityData();
	pData.Add( "MaxPitch", "360" );
	pData.Add( "MinPitch", "-360" );
	pData.Add( "MaxYaw", "90" );
	EntityCreator::Create( "prop_mounted_machine_gun", vSpawnPos, qAngles, pData );
}