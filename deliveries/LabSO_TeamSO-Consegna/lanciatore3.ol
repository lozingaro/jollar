constants {
  mylocat = "socket://localhost:8059"
}
init
{
	install( ErrorTest => exit)
}

include "terminale.ol"
