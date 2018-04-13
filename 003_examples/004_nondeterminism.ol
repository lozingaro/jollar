include "console.iol"
include "string_utils.iol"

main
{
	cities[0] = "Copenhagen";
	i = 0;
	while( i < #cities ) {
		println@Console( cities[i] )();
		{
			cities[i] = "Copenhagen" + i |
			i++
		}
	}
}