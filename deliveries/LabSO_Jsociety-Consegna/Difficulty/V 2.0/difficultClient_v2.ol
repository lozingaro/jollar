

// La difficoltà è un numero che regola quanto tempo impiegano i minatori per aggiungere nuovi blocchi di transazioni alla blockchain.
// È importante Perché garantisce che i blocchi di transazioni vengano aggiunti alla blockchain a intervalli regolari, anche se altri minatori si uniscono alla rete.
// In che modo la difficoltà controlla il tempo tra i blocchi ?:
	// Diciamo che ti do un intervallo di numeri da 1 a 100.
	// Ora, puoi generare casualmente un numero compreso tra 1 e 100 una volta al minuto. E il tuo obiettivo è quello di generare un numero sotto il mio numero target.
	// Pertanto, in base a quanti numeri puoi generare al minuto, posso scegliere una altezza per l'intervallo per controllare quanto tempo impieghi a trovare un numero vincente.



include "math.iol"
include "time.iol"
include "console.iol"
//include "message_digest.iol"

//non ti do direttamente il numero target, viene scelto dividento l'intervallo
//il numero che usiamo per dividere l'intervallo è la difficulty, ogni volta che viene scoperto un nuovo blocco passeremo al numero successivo secondo la catena di cunningham
//il numero sarà più grande quindi, nel range scelto avremo un intervallo più piccolo nel quale poter generare random un numero vincente.


init{
	
	timer = 60000;
	global.p[1] = 2; //numero per la catena di cunningham
	numeroScelto = 20; //vuol dire che la difficulty incrementa 20 volte, quindi con questo programma si possono scoprire fino a 20 blocchi (nella demo ne abbiamo 4!?)
	
	//genero un numero random all'inizio della blockchain
	random@Math()(randomNumb);
	sR = randomNumb*1000000000;
	global.startRange=long(sR);
	//divido per 2(primo numero della catena) quel numero, per ottenere il range
	global.difficultRange = global.startRange / global.p[1];
	println@Console("il divisore iniziale e' 2")()
}

main{

println@Console("il range globale va da 0 a : " + global.startRange)();
		println@Console("il range dentro al quale cercare il numero vincente va da 0 a " + global.difficultRange)();


	for ( i = 2, i < numeroScelto, i++) {


		
//devo generare random un numero tra 0 e startRange fino a quando non trovo il numero vincente, il numero vincente per trovare il blocco deve stare tra 0 e difficultRange
		println@Console("cerco il numero per trovare il blocco...")();
		random@Math()(result);
		res = result*1000000000;
		winnerNumber = long(res);


		while(winnerNumber > global.difficultRange){

			random@Math()(result);
			res = result*1000000000;
			winnerNumber = long(res);


			println@Console(winnerNumber)();
			println@Console("calculating...")();
            sleep@Time(1000)();//genero un numero ogni 1 secondi per evitare che un altro nodo scopra un numero vincente prima di me
            					//btc ne genera uno ogni 10 minuti per evitare che due nodi in contemporanea scoprano un numero vincente, 10 min e' un tempo
            					// sufficiente per aggiornare la blockchain, ho messo 1 secondo perche' e' una demo.

            if (winnerNumber < global.difficultRange){

            	println@Console("Hai trovato il numero " + winnerNumber + " minore del numero più alto del range  da 0 a " + global.difficultRange +  ", la difficulty aumenta")();
            	println@Console("Aggiornamento della blockchain...")();
					sleep@Time(10000)();//aspetto 10 secondi per iniziare un nuovo lavoro in modo da aggiornare la blockchain
				println@Console("Cerchiamo ora il nuovo blocco:")();

						//una volta trovato il numero aggiorno la catena di cunningham in modo da rendere piu' difficile la ricerca 
						op.base = 2;
						op.exponent = (i - 1);
						pow@Math(op)(potenza);
						p[i] = potenza * global.p[1] + (potenza - 1);
						global.p[1] = p[i];
						println@Console( "(nuova difficulty) " + global.p[1] + " e' il nuovo divisore")();
						//aggiorno il range utilizzand il nuovo numero della catena di cunningham
						global.difficultRange = global.startRange / global.p[1];
						println@Console("il nuovo range ora va da 0 a " + global.difficultRange)()
							}


								}

									}



//come potete notare più il numero della difficulty è alto, più tentativi (quindi tempo) ci vogliono per trovare il numero giusto

//il tempo tra la scoperta di un blocco e l'altro viene aumentato anche grazie all'impostazione di un tempo minimo tra la generazione di un numero casuale e l'altro

//il numero di partenza essendo una demo l'ho messo piccolo, tanto abbiamo un limite di 4 nodi non ha senso secondo me mettere un numero troppo grande

}
