const int HUD_CROSSHAIR_ICO = 47;
const int HUD_PRIMARY_CLIP_SEP_TXT = 48;
const int HUD_PRIMARY_CLIP_TXT = 49;
const int HUD_PRIMARY_TXT = 50;
const int HUD_PRIMARY_ICO = 51;
const int HUD_SECONDARY_TXT = 52;
const int HUD_SECONDARY_ICO = 53;

class CScriptHLWeaponBase : ScriptBase_Weapon
{
	protected int m_iClip2 = -1;
	protected string m_szCrosshair = "";
	protected string m_szAmmo1 = "";
	protected string m_szAmmo2 = "";

	void CheckMeleeEvent( CTerrorPlayer @pTerror )
	{
		// Refuse any and all melee attacks
	}

	void ItemBusyFrame()
	{
		OnHudPostFrame();
	}

	void ItemPostFrame()
	{
		OnHudPostFrame();
	}

	void OnHudPostFrame()
	{
		CTerrorPlayer@ pTerror = self.GrabOwner();
		if ( pTerror is null ) return;
		DrawAmmo( pTerror, true );
		if ( m_iClip2 > -1 )
			DrawAmmo( pTerror, false );
		DrawCrosshair( pTerror );
		// TODO: Hide the normal HUD (health & sprint)
	}

	void DrawCrosshair( CTerrorPlayer@ pTerror )
	{
		if ( Utils.StrEql( m_szCrosshair, "" ) ) return;
		// Draw the crosshair
		DrawASUI UIData;
		UIData.ID = HUD_CROSSHAIR_ICO;
		UIData.Type = UI_Texture;
		UIData.DrawType = UI_Center;
		UIData.HalfContentSize = true;
		UIData.Content = m_szCrosshair;
		UIData.DrawTime = 0.2f;
		UIData.Pos = Vector2D( 0, 0 );
		UIData.Size = Vector2D( 15, 15 );
		UIData.ColorContent = Color( 255, 255, 255, 255 );
		pTerror.UIDraw( UIData );
	}

	void DrawAmmo( CTerrorPlayer@ pTerror, bool bPrimary )
	{
		DrawASUI UIData;
		UIData.DrawType = UI_BottomRight;
		UIData.HalfContentSize = false;
		UIData.ColorContent = Color( 251, 126, 20, 255 );
		UIData.DrawTime = 0.2f;

		// Draw the icon
		string szCheckIcon = bPrimary ? m_szAmmo1 : m_szAmmo2;
		if ( !Utils.StrEql( szCheckIcon, "" ) )
		{
			UIData.Type = UI_Texture;
			UIData.ID = bPrimary ? HUD_PRIMARY_ICO : HUD_SECONDARY_ICO;
			UIData.Content = szCheckIcon;
			UIData.Pos = bPrimary ? Vector2D( 30, 28 ) : Vector2D( 30, 43 );
			UIData.Size = Vector2D( 15, 15 );
			pTerror.UIDraw( UIData );
		}

		// Draw the ammo count (if not primary, then draw the 2nd clip info)
		UIData.ID = bPrimary ? HUD_PRIMARY_TXT : HUD_SECONDARY_TXT;
		UIData.Type = UI_Text;
		UIData.Content = bPrimary ? formatInt( self.GetAmmoCount() ) : formatInt( m_iClip2 );
		UIData.Pos = bPrimary ? Vector2D( 50, 30 ) : Vector2D( 50, 45 );
		UIData.Size = Vector2D( 0, 0 );
		pTerror.UIDraw( UIData );

		if ( bPrimary )
		{
			// Draw Our clip
			UIData.ID = HUD_PRIMARY_CLIP_TXT;
			UIData.Content = formatInt( self.m_iClip );
			UIData.Pos = Vector2D( 140, 30 );
			pTerror.UIDraw( UIData );

			// Draw the seperator
			UIData.ID = HUD_PRIMARY_CLIP_SEP_TXT;
			UIData.Content = "       |";
			UIData.Pos = Vector2D( 140, 30 );
			pTerror.UIDraw( UIData );
		}
	}
}