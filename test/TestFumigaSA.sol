pragma solidity 0.8.1;
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/fumigaSA.sol";

contract TestFumigaSA {

struct datosDron{

	uint64 costeVuelo; 
	uint64 autonomia; 
	uint64 m2_por_minuto;
	uint64 alturaMax;
	uint64 alturaMin;
}


uint64[] pestizidas;
uint64[] pestizidas_expected;

 function testCrearDron() public {
    FumigaSA instancia = FumigaSA(DeployedAddresses.FumigaSA());
	
	datosDron memory datos;
	datosDron memory datosExpected;	
	uint64 expected = 0;

	uint64 totalDrones= instancia.getTotalDrones();
  	Assert.equal(totalDrones, expected, "Ya hay otros Drones creados");	
	
	//Datos expected
	datosExpected.alturaMax = 10;
	datosExpected.alturaMin = 5;
	datosExpected.costeVuelo=10;
	datosExpected.autonomia=120;
	datosExpected.m2_por_minuto=1;
	
	//Datos para dar de alta el Dron de prueba
	datos.alturaMax = 10;
	datos.alturaMin = 5;
	datos.costeVuelo=10;
	datos.autonomia=120;
	datos.m2_por_minuto=1;
	

	uint idDron= instancia.crearDron(tx.origin, datos.alturaMax , datos.alturaMin, datos.costeVuelo , datos.autonomia, datos.m2_por_minuto, pestizidas);
  
	uint totalDrones_expected=totalDrones+1;
	totalDrones= instancia.getTotalDrones();
    Assert.equal(totalDrones, totalDrones_expected , "La cantidad de Drones no se ha incrementado");
	
	
	//Se valida que todos los datos del Dron se hayan guardado correctamente
	(datos.costeVuelo, datos.autonomia, datos.m2_por_minuto,datos.alturaMax,datos.alturaMin) = instancia.datosDron(idDron);
	Assert.equal(datos.costeVuelo, datosExpected.costeVuelo, "El coste del vuelo deberia ser 10");
	Assert.equal(datos.autonomia,datosExpected.autonomia, "La autonomia deberia ser 120");
	Assert.equal(datos.m2_por_minuto,datosExpected.m2_por_minuto, "Los m2 de fumigacion por minuto deberia ser 1");
	Assert.equal(datos.alturaMax,datosExpected.alturaMax, "La altura maxima del Dron creado deberia ser 10");
	Assert.equal(datos.alturaMin, datosExpected.alturaMin, "La altura minima del Dron creado deberia ser 5");


	//Se valida que la situación del Dron sea "Pendiente"
	
	uint64 estado_expected=0;
	
	uint64 idParcela;
	uint64 estado_dron;
	uint64 pestizida;
	
	(idParcela,estado_dron,pestizida) = instancia.situacionDron(idDron);
	
	Assert.equal(estado_dron, estado_expected, "La situacion del Dron creado no es correcta");

  }
  

}

