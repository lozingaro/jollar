include "console.iol"
include "string_utils.iol"

main
{
	cities.Copenhagen.state = "Denmark";
	cities.Copenhagen.population = "1mil";
	
	// equiv. a cities.Rome.state = "Italy"
	cities.("Rome").state = "Italy";

	cityName = "Munich";
	// equiv. a cities.Munich.state = "Germany"
	cities.(cityName).state = "Germany";

	if ( !is_defined( cities.Munich.population ) ) {
		println@Console( "too bad" )()
		|
	foreach( city : cities ) {
		valueToPrettyString@StringUtils( cities.( city ) )( result );
		println@Console( result )()
		}
	}
}