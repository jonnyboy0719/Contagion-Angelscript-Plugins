namespace GeoIP
{
    string GrabLocation( const string &in address )
    {
        JsonValues@ json = FileSystem::ReadMMDB( address );
        if ( json is null ) return "Unknown";
        return FileSystem::GrabString( json, "country", "name_en" );
    }
}