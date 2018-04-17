include "console.iol"
include "string_utils.iol"

main
{
	team.person[0].name = "John";
	team.person[0].age = 30;
	team.person[1].name = "Jimmy";
	team.person[1].age = 24;

	team.sponsor = "Nike";
	team.ranking = 3;

	valueToPrettyString@StringUtils( team )( result )
}