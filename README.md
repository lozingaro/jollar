# Esercizi per il Laboratorio di Sistemi Operativi
## Professor Davide Sangiorgi
## Dr Stefano Pio Zingaro
Esercizi di consolidamento per l'insegnamento del linguaggio Jolie.
------------------------------------------------------------------

Nell'arco del corso verranno pubblicati una serie di esercizi utili a conseguire l'autonomia nella programmazione in *[Jolie](http://jolie-lang.org)*, la documentazione di *Jolie* è disponibile @ [Jolie Docs](https://docs.jolie-lang.org/).

###### 13 Aprile 2018
=====================
1) `sendNumber` da **Client** a **Server**, creare un servizio di invio di un input contenente un numero. Creare il relativo servizio di ricezione che stampa il numero ricevuto.

Esempio di input: **5**
Esempio di output: **Il numero inviato è 5**

- Le specifiche delle `operations` sono fornite di seguito:

```jolie
type snType: void {
    .x: int
}

interface MyInterface {
    OneWay: sendNumber( snType )
}
```

-  Il servizio A invia l'input al servizio B:

```jolie
include "interface.iol"
include "console.iol" // <- Console serve per stampare a video

outputPort B {
    /* INSERISCI IL DEPLOYMENT DI B */
}

/**** BEHAVIOUR A ****/
main
{
    /* INSERISCI IL BEHAVIOUR DI A */
}
```

- Il servizio B riceve il numero e stampa l'output:


```jolie
include "interface.iol"
include "console.iol" // <- Console serve per stampare a video

/*** DEPLOYMENT B ****/
inputPort B {
    /* INSERISCI IL DEPLOYMENT DI B */
}

/**** BEHAVIOUR B ****/
main
{
    /* INSERISCI IL BEHAVIOUR DI B */
}
```

[Vai alla soluzione](002_examples/client_server)

2) `calculator`, creare un servizio calcolatrice che offre l'operazione di somma tra due numeri interi, sia tramite protocollo **http** che **sodep** e restituisce la somma tra i due numeri in *output*. Creare anche un client che effettua una richiesta di somma e stampa il risultato. 

Esempio di input: **3,4** 
Esempio di output: **Il risultato della somma tra 3 e 4 è 7**

- L'interfaccia viene fornita di seguito:

```jolie
type SumRequest:void {
    .x:int
    .y:int
}

interface CalculatorInterface {
    RequestResponse: sum(SumRequest)(int)
}
```

- Il servizio *client* che effettua la richiesta di somma e stampa il risultato:

```jolie
include "interface.iol"
include "console.iol"

outputPort Calculator {
    /* INSERISCI IL DEPLOYMENT DEL client PER sodep */
}

/**** BEHAVIOUR client ****/
main
{
    /* INSERISCI IL BEHAVIOUR DEL client */
}
```

- Il servizio *calculator* che offre il servizio di somma, sia in sodep che http, per effettuare una richiesta in http basta andare con il browser alla pagina *http://localhost:8000/sum?x=5&y=6*:

```jolie
include "interface.iol"
include "console.iol"

/* costrutto di Jolie per mantenere l'esecuzione attiva ed accettare richieste in concorrenza */
execution{ concurrent } 

inputPort Calculator_http {
    Location: /* SCEGLI UNA LOCATION PER CALCULATOR HTTP */
    Protocol: http
    Interfaces: /* RICHIAMA L'INTERFACCIA COMUNE AI SERVIZI */
}

inputPort Calculator_sodep {
    Location: /* SCEGLI UNA LOCATION PER CALCULATOR SODEP */
    Protocol: sodep
    Interfaces: /* RICHIAMA L'INTERFACCIA COMUNE AI SERVIZI */
}

main
{
    sum( a )( b ) {
        /* INSERISCI IL BEHAVIOUR PER LA SOMMA */
    }
}
```

[Vai alla soluzione](002_examples/calculator)
