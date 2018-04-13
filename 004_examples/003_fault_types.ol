//server.ol
include "console.iol"

type MyFaultType: void{
	.number: int
	.faultError: string
}

interface GuessInterface {
	RequestResponse: guess throws faultNumber( MyFaultType )
}

inputPort Guess {
	Protocol: sodep
	Location: "socket://localhost:2000"
	Interfaces: GuessInterface
}

init {
	secret = 3
}

main
{
	install( fault_main =>
		println@Console( "A wrong number has been sent!" )()
	);
	scope( num_scope )
	{
		install( fault_number =>
			println@Console( "Wrong number sent!" )();
			throw( fault_main )
		);
		guess( number )( response ){
			if ( number == secret ) {
				println@Console( "Number guessed!" )();
				response = "You won!"
			}
			else {
				with( fault_error ){
					.number = number;
					.fault_error = "Wrong number, better luck next time!"
				};
				throw( fault_number, fault_error )
			}
		}
	}
}