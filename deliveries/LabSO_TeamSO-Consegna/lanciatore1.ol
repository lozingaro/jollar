constants {
  mylocat = "socket://localhost:8001"
}
init
{
	install( ErrorTest => exit)
}

include "terminale.ol"