shared enum PerkState
{
	k_eEnded = 0,
	k_eKilled,
	k_eDisconnected,
}

shared enum PerkType
{
	k_eUnknown = -1,
	k_eBad = 0,
	k_eNeutral,
	k_eGood
}

shared class IRollTheDiceTypeBase
{
	protected string m_ID;
	protected string m_Name;
	protected string m_Desc;
	protected float m_Time;
	protected bool m_NoRollEndNotify;
	protected PerkType m_PerkType;

	// Default
	IRollTheDiceTypeBase()
	{
		m_ID = "unknown_perk";
		m_Name = "UNKNOWN PERK";
		m_Desc = "This is a generic perk.";
		m_Time = 1.0f;
		m_PerkType = k_eUnknown;
		m_NoRollEndNotify = false;
	}

	string GetID() { return m_ID; }
	string GetName() { return m_Name; }
	string GetDesc() { return m_Desc; }
	float GetTime() { return m_Time; }
	bool NoRollEndNotify() { return m_NoRollEndNotify; }
	PerkType GetPerkType() { return m_PerkType; }

	HookReturnCode OnInfectedDamagedPre(Infected@ pInfected, CTakeDamageInfo &in DamageInfo) { return HOOK_CONTINUE; }
	HookReturnCode OnPlayerDamagedPre(CTerrorPlayer@ pPlayer, CTakeDamageInfo &in DamageInfo) { return HOOK_CONTINUE; }

	void OnRollEnd( CTerrorPlayer @pPlayer, PerkState ePerk ) {}
	void OnFireGameEvent( ASGameEvent &in event ) {}
	void OnRollStart( CTerrorPlayer@ pPlayer ) {}
	void ClearData() {}
}
