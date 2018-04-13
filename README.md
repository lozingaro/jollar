# Esercizi per il Laboratorio di Sistemi Operativi
## Professor Davide Sangiorgi
## Dr Stefano Pio Zingaro
Esercizi di consolidamento per l'insegnamento del linguaggio Jolie.
------------------------------------------------------------------

Nell'arco del corso verranno pubblicati una serie di esercizi utili a conseguire l'autonomia nella programmazione in *Jolie*.

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

-  Il servizio A invia l'input al servizio B

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

- Il servizio B riceve il numero e stampa l'output


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