const fumigaSA = artifacts.require("FumigaSA");
const assert = require("chai").assert;
const truffleAssert = require('truffle-assertions');

contract("fumigaSA", (accounts) => {

var instancia; 
var owner;

describe('Pruebas TF', async () => {

	beforeEach(async function () {
	 	instancia = await fumigaSA.deployed();

		
		let totalDrones=await instancia.getTotalDrones.call();
		let totalParcelas=await instancia.getTotalParcelas.call();
	
		owner= await instancia.owner();
		console.log("Numero de drones BEFORE:",totalDrones.toNumber());
		console.log("Numero de parcelas BEFORE:",totalParcelas.toNumber());


	});

describe('Happy path', async () => {

  it('Deberia crear una nueva Parcela', async () => {
    
	let totalParcelas_before=await instancia.getTotalParcelas();
    
	// Creo nueva Parcela y compruebo si el número de parcelas totales se ha incrementado
    const pestizidas = [1,2];

	await instancia.crearParcela(accounts[2],7,2,10,pestizidas, { from: accounts[2] });
	
	var totalParcelas_new=await instancia.getTotalParcelas();
    totalParcelas_before=parseInt(totalParcelas_before)+parseInt(1);
	
	assert.equal(totalParcelas_new, totalParcelas_before, "No se ha incrementado el numero de parcelas");
	
	
	// Obtengo los datos de la parcela creada y comparo con los esperados
	var datosParcela;
	datosParcela = await instancia.datosParcela(totalParcelas_new);
//     console.log("Total parcelas new",totalParcelas_new.toNumber());
	assert.equal(datosParcela.alturamax, 7, 'La altura maxima deberia ser 7');
	assert.equal(datosParcela.alturamin, 2, 'La altura minima deberia ser 2');
	assert.equal(datosParcela.m2superfice, 10, 'Los m2 de superficie deberían ser 10');
	assert.equal(datosParcela.owner_parcela, accounts[2] , 'El popietario es incorrecto');
	    
  });

  it('Deberia crear un nuevo Dron', async () => {
    

	let totalDrones_before=await instancia.getTotalDrones();
    const pestizidas = [1,2];

	// Creo nuevo Dron y compruebo si el número de drones totales se ha incrementado
    await instancia.crearDron(accounts[1],10,5,10,120,1,pestizidas, { from: accounts[1] });

	var totalDrones_new=await instancia.getTotalDrones();
    totalDrones_before=parseInt(totalDrones_before)+parseInt(1);
	
	assert.equal(totalDrones_new, totalDrones_before, "No se ha incrementado el numero de drones");
	
	
	// Obtengo los datos del dron creado y comparo con los esperados
	var datosDron;
	datosDron = await instancia.datosDron(totalDrones_new);

	assert.equal(datosDron.costeVuelo, 10, "El coste del vuelo deberia ser 10");
	assert.equal(datosDron.autonomia,120, "La autonomia deberia ser 120");
	assert.equal(datosDron.m2_por_minuto,1, "Los m2 de fumigacion por minuto deberia ser 1");
	assert.equal(datosDron.alturamax,10, "La altura maxima del Dron creado deberia ser 10");
	assert.equal(datosDron.alturamin, 5, "La altura minima del Dron creado deberia ser 5");
	    
  });

  it('Deberia contratar fumigacion Dron/Parcela', async () => {
	   //instancia = await fumigaSA.deployed();
       
	   let totalDrones=await instancia.getTotalDrones.call();
	   let totalParcelas=await instancia.getTotalParcelas.call();
	    
	// Contrato fumigacion con el ultimo Dron y Parcelas creados
    await instancia.contratarFumigacion(totalParcelas.toNumber(),totalDrones.toNumber(),1, {from: accounts[2] });
	
	var estado_expected=1; //Activo
    let situacionDron = await instancia.situacionDron.call(totalDrones.toNumber());
	
	assert.equal(situacionDron.idEstado, estado_expected, "La tuplca Dron/Parcela no esta activa");
	
  	});

  });


describe('Dron/Parcela no compatibles', async () => {

 it('Deberia crear una nueva Parcela', async () => {
    
	let totalParcelas_before=await instancia.getTotalParcelas();
    
	// Creo nueva Parcela y compruebo si el número de parcelas totales se ha incrementado
    const pestizidas = [2,3];

	await instancia.crearParcela(accounts[2],2,1,10,pestizidas, { from: accounts[2] });
	
	var totalParcelas_new=await instancia.getTotalParcelas();
    totalParcelas_before=parseInt(totalParcelas_before)+parseInt(1);
	
	assert.equal(totalParcelas_new, totalParcelas_before, "No se ha incrementado el numero de parcelas");
	    
  });

  it('Deberia crear un nuevo Dron', async () => {
    

	let totalDrones_before=await instancia.getTotalDrones();
    const pestizidas = [1,4];

	// Creo nuevo Dron y compruebo si el número de drones totales se ha incrementado
    await instancia.crearDron(accounts[1],10,5,10,120,1,pestizidas, { from: accounts[1] });

	var totalDrones_new=await instancia.getTotalDrones();
    totalDrones_before=parseInt(totalDrones_before)+parseInt(1);
	
	assert.equal(totalDrones_new, totalDrones_before, "No se ha incrementado el numero de drones");
		   
  });

  it('No deberia haber compatiblidad entre Dron y Parcela', async () => {
	          
	   let totalDrones=await instancia.getTotalDrones.call();
	   let totalParcelas=await instancia.getTotalParcelas.call();

	// Compruebo compatiblidad entre el ultimo Dron y Parcelas creados
	var result= await instancia.compatibilidadDronParcela(totalParcelas.toNumber(),totalDrones.toNumber());
	console.log("resultado:",result.valueOf());
	assert.equal(result.valueOf(),false, "Dron/Parcela no deberian ser compatibles");
	});

  });

////////////////////////////////////////////////////////////////////////////////////////////////////

describe('OnlyOwner puede Fumigar', async () => {

  
  it('Deberia dejar Fumigar porque es el Owner', async () => {
	   
	
		var tx= await instancia.fumigacionParcela(1,1, {from: owner});

		//console.log("result:", result.valueOf());
		//assert.equal(result.status, true, "Debería haber dejado fumigar");

		truffleAssert.eventEmitted(tx, 'ParcelaFumigadaLog', (ev) => {
        return (ev.idParcela == 1 && ev.idDron== 1);
    	});

			
		
  	});

	it('No deberia dejar Fumigar porque NO es el Owner', async () => {
	  
	
		var tx= await instancia.fumigacionParcela(1,1, {from: accounts[2]});
		truffleAssert.eventNotEmitted(tx, 'ParcelaFumigadaLog', (ev) => {
    		return (ev.idParcela == 1 && ev.idDron== 1);
		});

	
  	});


  });

});  
});

	


