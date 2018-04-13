include "console.iol"
include "string_utils.iol"

type Team:void {
	.person?:void {
		.name:string
		.age:int
	}
	.sponsor:string
	.ranking:int
}

interface MyInterface {
OneWay: sendTeam(Team)
}

main
{
	// team = 5;
	team.person[0].name = "John";
	team.person[0].age = 30;
	team.person[1].name = "Jimmy";
	team.person[1].age = 24;

	team.sponsor = "Nike";
	team.ranking = 3;

	foreach ( item : team ) {
		println@Console( team.( item ) )()
	};

	valueToPrettyString@StringUtils( team.person )( result );
	println@Console( result )()
}
