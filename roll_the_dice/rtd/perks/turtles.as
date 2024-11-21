#include "turtles_ent.as"

namespace RTD
{
	namespace Turtles
	{
		array<int> m_iPlayers;
		bool IsValidIndex( int client )
		{
			for ( uint y = 0; y < m_iPlayers.length(); y++ )
			{
				int index = m_iPlayers[y];
				if ( index == client )
					return true;
			}
			return false;
		}

		void RemoveFromList( int client )
		{
			for ( uint y = 0; y < m_iPlayers.length(); y++ )
			{
				int index = m_iPlayers[y];
				if ( index == client )
				{
					m_iPlayers.removeAt(y);
					break;
				}
			}
		}

		void SpawnTurtle( CTerrorPlayer @pTerrorPlayer )
		{
			// Calculate position that the player is looking at.
			Vector vec_start = pTerrorPlayer.GetAbsOrigin() + Vector( Math::RandomFloat( -45, 45 ), Math::RandomFloat( -45, 45 ), 150 );
			ICustomEntity @pEnt = CustomEnts::Cast( EntityCreator::Create( "turtle_heaven", vec_start, pTerrorPlayer.EyeAngles() ) );
			RTD::CPerkTurtleHeavenEnt @pTurtle = cast<RTD::CPerkTurtleHeavenEnt>( pEnt );
			if ( pTurtle is null ) return;
			Vector	vecThrow( 0, 0, 0 );
			pTurtle.Setup( vecThrow );
		}

		void Think( int client )
		{
			if ( !IsValidIndex( client ) ) return;
			CTerrorPlayer @pTarget = ToTerrorPlayer( client );
			SpawnTurtle( pTarget );
			Schedule::Task( 0.3, client, RTD::Turtles::Think );
		}
	}

	class CPerkTurtles : IRollTheDiceTypeBase
	{
		CPerkTurtles()
		{
			m_ID = "turtles";
			m_Name = "Turtle Heaven";
			m_Desc = "Turtles will rain all around you.";
			m_Time = 5.0f;
			m_PerkType = k_eNeutral;
			g_rtd.RegisterItem( this );
			Engine.PrecacheFile( model, "models/props_laststop/turtle.mdl" );
			RegisterData();
		}

		void OnRollEnd( CTerrorPlayer @pPlayer, PerkState ePerk )
		{
			if ( pPlayer is null ) return;
			Turtles::RemoveFromList( pPlayer.entindex() );
		}

		void ClearData()
		{
			Turtles::m_iPlayers.removeRange(0, Turtles::m_iPlayers.length() - 1);
			RegisterData();
		}

		void RegisterData()
		{
			EntityCreator::RegisterCustomEntity( k_eCustomEntity, "turtle_heaven", "RTD::CPerkTurtleHeavenEnt" );
		}

		void OnRollStart( CTerrorPlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			if ( Turtles::IsValidIndex( pPlayer.entindex() ) ) return;
			Turtles::m_iPlayers.insertLast( pPlayer.entindex() );
			Schedule::Task( 0.01, pPlayer.entindex(), RTD::Turtles::Think );
		}
	}
}