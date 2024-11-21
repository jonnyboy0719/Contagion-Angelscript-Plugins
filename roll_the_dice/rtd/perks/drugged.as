namespace RTD
{
	array<int> m_iDruggedPlayers;
	bool IsValidIndex( int client )
	{
		for ( uint y = 0; y < m_iDruggedPlayers.length(); y++ )
		{
			int index = m_iDruggedPlayers[y];
			if ( index == client )
				return true;
		}
		return false;
	}

	void RemoveFromList( int client )
	{
		for ( uint y = 0; y < m_iDruggedPlayers.length(); y++ )
		{
			int index = m_iDruggedPlayers[y];
			if ( index == client )
			{
				m_iDruggedPlayers.removeAt(y);
				break;
			}
		}
	}

	void DoDruggedThink( int client )
	{
		if ( !IsValidIndex( client ) ) return;
		
		// Grab our client and punch the screen to random angles
		CTerrorPlayer @pTarget = ToTerrorPlayer( client );
		QAngle angles = pTarget.GetPunchAngle();
		angles.x -= Math::RandomFloat(-45.0, 45.0);
		angles.y -= Math::RandomFloat(-45.0, 45.0);
		angles.z -= Math::RandomFloat(-45.0, 45.0);
		pTarget.SetPunchAngle( angles );
		
		// Use the fade UserMessage to fake being drugged
		UserMessage.Begin( ToTerrorPlayer(client), "Fade" );
			UserMessage.WriteShort( 255 );
			UserMessage.WriteShort( 255 );
			UserMessage.WriteShort( (0x0002) );
			UserMessage.WriteByte( Math::RandomInt(0,255) );
			UserMessage.WriteByte( Math::RandomInt(0,255) );
			UserMessage.WriteByte( Math::RandomInt(0,255) );
			UserMessage.WriteByte( 128 );
		UserMessage.End();
		
		Schedule::Task( 1.0, client, RTD::DoDruggedThink );
	}

	class CPerkDrugged : IRollTheDiceTypeBase
	{
		CPerkDrugged()
		{
			m_ID = "drugged";
			m_Name = "Drugged";
			m_Desc = "You will become \"drugged\" for about 8 seconds.";
			m_Time = 8.0f;
			m_PerkType = k_eBad;
			g_rtd.RegisterItem( this );
		}

		void OnRollEnd( CTerrorPlayer @pPlayer, PerkState ePerk )
		{
			if ( pPlayer is null ) return;
			RemoveFromList( pPlayer.entindex() );
		}

		void ClearData()
		{
			m_iDruggedPlayers.removeRange(0, m_iDruggedPlayers.length() - 1);
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			if ( IsValidIndex( pPlayer.entindex() ) ) return;
			m_iDruggedPlayers.insertLast( pPlayer.entindex() );
			Schedule::Task( 1.0, pPlayer.entindex(), RTD::DoDruggedThink );
		}
	}
}