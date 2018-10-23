include "MainInterface.iol"
include "math.iol"
include "console.iol" 

inputPort LocalInPow {
	Location: "local" 
	Interfaces: PowInterface
}


execution{ concurrent}

//implementazione catena di Cunnngham del primo tipo
define CunPrimoTipo
{
	for ( i = 0, i < n, i++ ) {
        
		p[i+1] = (2*p[i]) + 1;
		c[i] = p[i+1]
		
	}
}

//implementazione catena di Cunnngham del secondo tipo
define CunSecondoTipo
{
  for ( i = 0, i < n, i++ ) {
        
    p[i+1] = (2*p[i]) - 1;
    c[i] = p[i+1]
    
  }
  
}

//implementazione catena biTwin
define BiTwin
{
  for ( i = 0, i < n, i++ ) {
  
    kRequest.base = 2;
    kRequest.exponent= i;    
    pow@Math(kRequest)(risultatoK);
    
      p[i+1] = (risultatoK*p[0]) - 1; 
      c[i] = p[i+1];     
         
      p[i+2] = (risultatoK*p[0]) +  1; 
      c[i+1] = p[i+2] 
  }  
}

//esecuzione test di Fermat
define TestFermat
{
   
  powRequest.base = 2;
  powRequest.exponent= primo - 1;

	pow@Math(powRequest)(risultatoPow); 

  if (risultatoPow%primo == 1) {
    ePrimo = true
	}
	else {
		ePrimo = false
	}

}

//controlla che la lunghezza della catena sia maggiore della difficulty
define CheckLunghDiff 
{

  if (lunghezzaCat >= difficolta){
  	maggiore = true
  } else {
    maggiore = false
  }

}


//proof of work
define PoW
{

	random@Math()(numeroR );
  numero = (int(numeroR*10))%3;

 
  if (numero == 0) {
    CunPrimoTipo;
    println@Console( "Genero catena CunPrimoTipo" )() 
  } else if (numero == 1) {
    CunSecondoTipo;
    println@Console( "Genero catena CunSecondoTipo" )() 
  } else if (numero == 2) {  
    BiTwin;
    println@Console( "Genero catena BiTwin" )() 
  }; 
  
  println@Console(p[0])();


  for ( i = 0, i < n, i++ ) {
  	println@Console(c[i])();
	  primo = c[i];
  	TestFermat;
 
    
  //resto del test di Fermat del prossimo numero in catena pk.
	for ( j = i, j < (i+1), j++ ) {
		
		primoSuccessivo = c[j];
		primo = primoSuccessivo;
    TestFermat;
    r = risultatoPow%primo
  }

 
  };
  
  difficolta = double(n + ((primo-r) / primo));
  println@Console("la difficulty è  " + difficolta)();
  responsePow.difficulty = difficolta;
	lunghezzaCat= n+1;
  CheckLunghDiff;

  if (maggiore == true){
  		println@Console("la lunghezza della catena è >= della difficolta " )()
 	} else {
    	println@Console("la lunghezza della catena è < della difficolta " )()
 	};


 	if( (maggiore == true)&&(ePrimo == true) ) {
 	  	responsePow.validita = true
 	} else {
 		responsePow.validita  = false
 	}
 	
   
}


main
{
  [givePoW(request)(responsePow){
  	
  	p[0] = request.x;
  	n = request.y; //lunghezza della catena
  	PoW
  }]
 
}


