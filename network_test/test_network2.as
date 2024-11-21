
void OnPluginInit()
{
	PluginData::SetName( "TEST NETWORK 2" );
}

//------------------------------------------------------------------------------------------------------------------------//

void BB2_OnTimeRanOut( NetObject@ pData )
{
	Chat.PrintToChat( all, "{arcana}Function {azure}BB2_OnTimeRanOut{arcana} was executed!" );
}

void BB2_TestNetwork( NetObject@ pData )
{
	Chat.PrintToChat( all, "{arcana}Function {azure}BB2_TestNetwork{arcana} was executed!" );
    // Make sure we aren't invalid
    if ( pData is null ) return;
	if ( pData.HasIndexValue( 0 ) )
		Chat.PrintToChat( all, "{arcana}HasIndexValue >> 0 {azure}" + pData.GetString( 0 ) );
	if ( pData.HasIndexValue( 1 ) )
		Chat.PrintToChat( all, "{arcana}HasIndexValue >> 1 {azure}" + pData.GetInt( 1 ) );
}