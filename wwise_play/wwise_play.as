bool Debug = true;

void OnPluginInit()
{
	PluginData::SetVersion("1.0");
	PluginData::SetAuthor("Chicken Panic Inc.");
	PluginData::SetName("Simple Wwise Playback");
	Events::Player::PlayerSay.Hook(@WSNDSay);
}

HookReturnCode WSNDSay(CTerrorPlayer@ pPlayer, CASCommand@ pArgs)
{
	if (pPlayer is null || pArgs is null) return HOOK_HANDLED;
	string Arg = pArgs.Arg(1);

	if( Utils.StrContains( "!emit", Arg ) || Utils.StrContains( "!emitpos", Arg ) )
	{
		CASCommand@ pSplit = StringToArgSplit( Arg, " " );

		if( Utils.StrEql( "", pSplit.Arg(1), true) )
		{
			Chat.PrintToChat ( pPlayer, "{orange}No Valid Value" );
			pPlayer.PlayWwiseSound( "UI2_ChatNotify", "", 1.0f );
			return HOOK_HANDLED;
		}

		CBasePlayer@ pBasePlr = pPlayer.opCast();
		CBaseEntity@ pBaseEnt = pBasePlr.opCast();

		if(pSplit.Arg(0) == "!emitpos")
		{
			// Calculate position that the player is looking at.
			const Vector vecEyes = pPlayer.EyePosition();

			Vector vec;
			Globals.AngleVectors( pPlayer.EyeAngles(), vec );

			CGameTrace tr;
			Vector vec_end = vecEyes + vec * 500;
			Utils.TraceLine( vecEyes, vec_end, MASK_SHOT, pPlayer, COLLISION_GROUP_NONE, tr );

			Vector EmitPos = tr.endpos;

			if(Debug) CreateMarker(EmitPos);
			Chat.PrintToChat( pPlayer, "{gold}Playing sound - {green}" + pSplit.Arg(1) + "{gold} at {white}" + EmitPos.x + " " + EmitPos.y + " " + EmitPos.z );
			Engine.EmitSoundPosition( pSplit.Arg(1), EmitPos );
		}
		else
		{
			if(pBaseEnt !is null)
			{
				if(Debug) CreateMarker( pBaseEnt.EyePosition() );
				Chat.PrintToChat( pPlayer, "{gold}Playing sound - {green}" + pSplit.Arg(1) + "{gold} at Entity {white}" + pBaseEnt.entindex() );
				Engine.EmitSoundEntity( pBaseEnt, pSplit.Arg(1) );
			}
		}
		return HOOK_HANDLED;
	}
	return HOOK_CONTINUE;
}

void CreateMarker(const Vector &in EmitPos)
{
	string MDL1 = "models/editor/axis_helper_thick.mdl";
	Engine.PrecacheFile(model, MDL1);
	CEntityData@ ITEM = EntityCreator::EntityData();
	ITEM.Add("model", MDL1);
	ITEM.Add("spawnflags", "256");
	ITEM.Add("solid", "0");
	ITEM.Add("targetname", "tempdyn_" );
	ITEM.Add( "kill", "", true, "1.5" );
	EntityCreator::Create( "prop_dynamic_override", EmitPos, QAngle(0, 0, 0), ITEM );
}
