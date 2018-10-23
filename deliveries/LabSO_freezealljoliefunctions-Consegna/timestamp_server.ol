include "console.iol"
include "nodo_interface.iol"
include "time.iol"
include "semaphore_utils.iol"

execution{concurrent}

// porta d'ascolto

inputPort TimeIn {
	Location: "socket://localhost:9000"
	Protocol: sodep
	Interfaces: Nodo_interface
}

// porta per contattare i nodi (utilizza binding dinamico)

outputPort NodoContact {
	Protocol: sodep
	Interfaces: Nodo_interface
}

// inizializzo numero di nodi online e due semafori, il primo a 1 e il secondo a 3

init
{
	global.semaphore.name = "Primo";
	global.semaphore.permits = 1;
  	global.nodiOnline = 0;
  	global.semaphore2.name = "Secondo";
  	global.semaphore2.permits = 3;
  	release@SemaphoreUtils(global.semaphore)(confermaSemaphore);
  	release@SemaphoreUtils(global.semaphore2)(confermaSemaphore);
  	release@SemaphoreUtils(global.semaphore2)(confermaSemaphore);
  	release@SemaphoreUtils(global.semaphore2)(confermaSemaphore)
}

main {

	// metodo per prendere semaforo (il chiamante passa un int che indica quale semaforo)

	[
		prendiSemaforo(numeroSemaforo)()
		{
			if (numeroSemaforo == 1) {
				acquire@SemaphoreUtils(global.semaphore)(confermaSemaphore)
			} else {
				acquire@SemaphoreUtils(global.semaphore2)(confermaSemaphore)
			}
		}
	]

	// metodo per rilasciare semaforo

	[
		lasciaSemaforo(numeroSemaforo)()
		{
			if (numeroSemaforo == 1) {
				release@SemaphoreUtils(global.semaphore)(confermaSemaphore)
			} else {
				release@SemaphoreUtils(global.semaphore2)(confermaSemaphore)
			}
		}
	]

	// restituisce timestamp

	[
		getTimestamp()(response)
		{
			getCurrentTimeMillis@Time()(millis);
			response = millis
		}
	]

	// i nodi contattano questo servizio per aggiornare la lista dei nodi online e conoscere la propria location

	[
		notifyServer()(b)
		{
			println@Console("Mi e' arrivata una richiesta di connessione")();
			synchronized(syncToken) 
			{
				b = "socket://localhost:800" + global.nodiOnline;
				global.lista.porta[global.nodiOnline] = b;

				println@Console("Assegno al nodo la location " + b)();


				if (#global.lista.porta > 1) {
					println@Console("Avviso gli altri nodi di aggiornare le proprie liste")()
				};
				for (j = 0, j < #global.lista.porta - 1, j++)
				{
					NodoContact.location = global.lista.porta[j];
					aggiornaLocations@NodoContact();
					println@Console("Ho aggiornato il nodo " + global.lista.porta[j])()
				};

				global.nodiOnline++ 
			}
		}
	]

	// i nodi contattano questo servizio per avere la lista dei nodi online

	[
		getLocations()(b)
		{
			b << global.lista
		}
	]


}