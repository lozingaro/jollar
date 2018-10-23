// metodo per il calcolo della proof of work
define proofOfWork{
		//calcola random un numero tra 1 e 5
		//ogni numero viene associato ad un algoritmo della proof of work
		random@Math()(numeroRandom);
	 	randomNumb = numeroRandom * 5 ;
	 	round@Math(randomNumb)(numb);


	 	if( numb == 0 ) {
	 		boolean = false

	 	};

	 	if( numb == 1 ) {

			  for ( i = 1, i < 6, i++ ) {
					n = 2;
					p1 = n;
				  prova.base = n;
					prova.exponent = i - 1;
					pow@Math(prova)(risultato);
					p = ((risultato * p1)+(risultato - 1));
					array1pt[i] = p
				};

			  //convalida Fermat
			  for ( i = 1, i < #array1pt, i++ ) {
			    	test.base = 2;
			    	test.exponent = array1pt[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array1pt[i];
			    	if( p1 != 1 ) {
			    	  boolean = false
			    	} else {
			    	  boolean = true
			    	}
			  	};

			  	origin = array1pt[1];
			  	difficult = origin / p1;
			  	chainLength = 5
			 
			} else if ( numb == 2 ) {

			  for ( i = 1, i < 6, i++ ) {
					n = 3;
					p1 = n;
				  prova.base = n;
					prova.exponent = i - 1;
					pow@Math(prova)(risultato);
					p = ((risultato * p1)+(risultato - 1));
					array2pt[i] = p
				};

			  //convalida Fermat
			  for ( i = 1, i < #array2pt, i++ ) {
			    	test.base = 2;
			    	test.exponent = array2pt[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array2pt[i];
			    	if( p1 != 1 ) {
			    	  boolean = false
			    	} else {
			    	  boolean = true
			    	}
			  	};

			  	origin = array2pt[1];
			  	difficult = origin / p1;
			  	chainLength = 5

			} else if ( numb == 3 ) {

			  for ( i = 1, i < 6, i++ ) {
					n = 5;
					p1 = n;
				  prova.base = n;
					prova.exponent = i - 1;
					pow@Math(prova)(risultato);
					p = ((risultato * p1)+(risultato - 1));
					array3pt[i] = p
				};

			  //convalida Fermat
			  for ( i = 1, i < #array3pt, i++ ) {
			    	test.base = 2;
			    	test.exponent = array3pt[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array3pt[i];
			    	if( p1 != 1 ) {
			    	  boolean = false
			    	} else {
			    	  boolean = true
			    	}
			  	};

			  	origin = array3pt[1];
			  	difficult = origin / p1;
			  	chainLength = 5
	
			} else if ( numb == 4 ) {

			  for ( i = 1, i < 6, i++ ) {
					n = 7;
					p1 = n;
				  prova.base = n;
					prova.exponent = i - 1;
					pow@Math(prova)(risultato);
					p = ((risultato * p1)+(risultato - 1));
					array4pt[i] = p
				};

			  //convalida Fermat
			  for ( i = 1, i < #array4pt, i++ ) {
			    	test.base = 2;
			    	test.exponent = array4pt[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array4pt[i];
			    	if( p1 != 1 ) {
			    	  boolean = false
			    	} else {
			    	  boolean = true
			    	}
			  	};

			  	origin = array4pt[1];
			  	difficult = origin / p1;
			  	chainLength = 5

			} else if ( numb == 5 ) {

			  for ( i = 1, i < 6, i++ ) {
					n = 11;
					p1 = n;
				  prova.base = n;
					prova.exponent = i - 1;
					pow@Math(prova)(risultato);
					p = ((risultato * p1)+(risultato - 1));
					array5pt[i] = p
				};


			  //convalida Fermat
			  for ( i = 1, i < #array5pt, i++ ) {
			    	test.base = 2;
			    	test.exponent = array5pt[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array5pt[i];
			    	if( p1 != 1 ) {
			    	  boolean = false
			    	} else {
			    	  boolean = true
			    	}
			  	};

			  	origin = array5pt[1];
			  	difficult = origin / p1;
			  	chainLength = 5
			
			}
} 
