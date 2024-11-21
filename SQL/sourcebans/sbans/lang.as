namespace Translate
{
	class CLanguage
	{
		string szFile;
		JsonValues @Keys;
	}
	array<CLanguage@> m_Lang;
	string m_ReadFile;

	void Init()
	{
		m_Lang.removeRange( 0, m_Lang.length() - 1 );
		m_ReadFile = "";
	}

	// Check if we already have said translation added to memory
	CLanguage @TranslationExist( const string &in szFile )
	{
		for ( uint t = 0; t < m_Lang.length(); t++ )
		{
			if ( Utils.StrEql( szFile, m_Lang[ t ].szFile ) )
				return m_Lang[ t ];
		}
		return null;
	}

	void AddTranslation( const string &in szFile )
	{
		if ( TranslationExist( szFile ) !is null )
		{
			Log.PrintToServerConsole( LOGTYPE_WARN, "language/" + szFile + ".json is already added." );
			return;
		}

		JsonValues@ temp = FileSystem::ReadFile( "language/" + szFile );
		if ( temp is null )
		{
			Log.PrintToServerConsole( LOGTYPE_ERROR, "language/" + szFile + ".json file does not exist." );
			return;
		}

		// Add to memory
		CLanguage @pLang = CLanguage();
		pLang.szFile = szFile;
		@pLang.Keys = temp;
		m_Lang.insertLast( pLang );
	}

	void RemoveTranslation( const string &in szFile )
	{
		for ( uint t = 0; t < m_Lang.length(); t++ )
		{
			if ( Utils.StrEql( szFile, m_Lang[ t ].szFile ) )
			{
				m_Lang.removeAt( t );
				break;
			}
		}
	}

	void SetFile( const string &in szFile )
	{
		m_ReadFile = szFile;
	}

	string GrabTranslation( const string &in szLang, const string &in szValue )
	{
		CLanguage @pTranslation = TranslationExist( m_ReadFile );
		if ( pTranslation is null ) return "";
		return FileSystem::GrabString( pTranslation.Keys, szLang, szValue );
	}

	string GrabTranslationFormat( const string &in szLang, const string &in szValue, const array<string> inputs )
	{
		CLanguage @pTranslation = TranslationExist( m_ReadFile );
		if ( pTranslation is null ) return "";
		string strArg = FileSystem::GrabString( pTranslation.Keys, szLang, szValue );
		for ( uint x = 0; x < inputs.length(); x++ )
		{
			int y = x+1;
			strArg = Utils.StrReplace( strArg, "%" + formatInt( y ), inputs[ x ] );
		}
		return strArg;
	}
}