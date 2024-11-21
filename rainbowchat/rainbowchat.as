
//------------------------------------------------------------------------------------------------------------------------//

// Include the color gradiant from the maps folder
#include "../maps/util_color_gradiant.as"

// The global static class for the rainbow
UTIL::ColorGradient::RainBow gColorRainBow;

//------------------------------------------------------------------------------------------------------------------------//

void OnPluginInit()
{
	PluginData::SetVersion( "1.0" );
	PluginData::SetAuthor( "JonnyBoy0719" );
	PluginData::SetName( "Rainbow Chat" );
	Events::Player::PlayerSay.Hook( @OnPlayerSay );
}

//------------------------------------------------------------------------------------------------------------------------//

void RainBowText( CTerrorPlayer@ pPlayer, string szText )
{
	string text_out = "\x0780FF00" + pPlayer.GetPlayerName() + " : ";
	uint maxlength = szText.length();
	for ( uint x = 0; x < maxlength; x++ )
	{
		string text = szText.substr(x, 1);
		if ( text.isEmpty() ) continue;
		// If empty, then don't do any hex stuff, since it will break apart.
		if ( text == " " )
		{
			text_out += " ";
			continue;
		}
		// Convert our color to interger
		int output;
		float ratio = (float(x+1) / float(maxlength));
		Utils.ColorToHex( gColorRainBow.GetColorForValue( ratio ), output );
		// Convert the number to an actual readable HEX value
		string hex = formatInt( output, 'H', 6 );
		text_out += "\x07" + hex + text;
	}
	Chat.PrintToChat( all, text_out );
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerSay( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	string arg1 = pArgs.Arg( 1 );
	// Rainbow text! WHOOOO
	RainBowText( pPlayer, arg1 );
	return HOOK_HANDLED;
}
