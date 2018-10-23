//Catena di cunningham con centro 6= 5, 7, 11, 13, 23, 47, 97, 191, 193, 383
//Catena di cunningham con centro 2= 3, 5, 7, 17, 31, 127, 257

//The difficulty is a number that regulates how long it takes for miners to add new blocks of transactions to the blockchain.
//Is important Because it ensures that blocks of transactions are added to the blockchain at regular intervals, even as more miners join the network.
//How does the difficulty control time between blocks?:
	//Let’s say I give you a range of numbers from 1 to 100.
	//Now, you are able to randomly generate a number between 1 and 100 once every minute. And your goal is to generate a number below my target number.
	//Therefore, based on how many numbers you are able to generate per minute, I can use the height of the target to control how long it takes you to find a winning number.

// La difficoltà è un numero che regola quanto tempo impiegano i minatori per aggiungere nuovi blocchi di transazioni alla blockchain.
// È importante Perché garantisce che i blocchi di transazioni vengano aggiunti alla blockchain a intervalli regolari, anche se altri minatori si uniscono alla rete.
// In che modo la difficoltà controlla il tempo tra i blocchi ?:
	// Diciamo che ti do un intervallo di numeri da 1 a 100.
	// Ora, puoi generare casualmente un numero compreso tra 1 e 100 una volta al minuto. E il tuo obiettivo è quello di generare un numero sotto il mio numero target.
	// Pertanto, in base a quanti numeri puoi generare al minuto, posso scegliere una altezza per l'intervallo per controllare quanto tempo impieghi a trovare un numero vincente.



include "math.iol"
include "console.iol"
//include "message_digest.iol"

//non ti do direttamente il numero target, viene scelto dividento l'intervallo
//il numero che usiamo per dividere l'intervallo è la difficulty, ogni volta che viene scoperto un nuovo blocco passeremo al numero successivo secondo la catena di cunningham
//il numero sarà più grande quindi, nel range scelto avremo un intervallo più piccolo nel quale poter generare random un numero vincente.


init{
	
	global.difficulty = 5
}



main{

//genero un numero random all'inizio della blockchain
random@Math()(randomNumb);
sR = randomNumb*1000000000;
startRange=long(sR);
//divido per 6 quel numero, per ottenere il range
difficultRange = startRange / global.difficulty;
println@Console("il range globale va da 0 a : " + startRange)();
println@Console("il range dentro al quale cercare il numero vincente va da 0 a " + difficultRange)();

//devo generare random un numero tra 0 e startRange, il numero vincente per trovare il blocco deve stare tra 0 e difficultRange
println@Console("cerco il numero per trovare il blocco")();
random@Math()(result);
res = result*1000000000;
winnerNumber = long(res);

while(winnerNumber > difficultRange){
random@Math()(result);
res = result*1000000000;
winnerNumber = long(res);


println@Console(winnerNumber)();

if (winnerNumber < difficultRange){

println@Console("Hai trovato un numero minore del numero più alto del range, la difficulty aumenta")();
println@Console("Puoi ora tentare di trovare il nuovo blocco")()

}
}

//una volta trovato tale numero si aggiorna la difficulty secondo il successivo numero della catena di cunningham

//... codice cunningham
	//... global.difficulty = NUOVO NUMERO



//come potete notare più il numero della difficulty è alto, più tentativi (quindi tempo) ci vogliono per trovare il numero giusto

//si può aumentare il tempo tra un blocco e l'altro mettendo anche un tempo minimo tra la generazione di un numero casuale e l'altro

//il numero di partenza essendo una demo l'ho messo piccolo, tanto abbiamo un limite di 4 nodi non ha senso secondo me mettere un numero troppo grande

}
