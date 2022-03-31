// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "./FumiTokenColeccion.sol";

// Este contrato hereda de FUMITOKEN 
//Token de drones
contract DronTokenColeccion is  FumiTokenColeccion  {
//using Counters for Counters.Counter;

struct datosDron {
    uint256 costeVueloDron;
    uint256 autonomia;
    uint256 m2_por_minuto;

}
mapping(uint256 => datosDron) listaDetalleDron;

   //constructor(string memory name, string memory symbol) FumiToken(name,symbol) {}

   constructor(string memory name, string memory symbol)  FumiTokenColeccion(name, symbol)  {}

   event eventmintDron (uint256 tokenId, address to, address muyself);
   function mint(address to, uint256 alturaMax, uint256 alturaMin, uint256 costeVuelo, uint256 autonomia, uint256 m2_por_minuto, uint256[] memory fertilizantes)  public returns (uint256 result)     {
  
        uint256 tokenId = super.mint(to, alturaMax, alturaMin, fertilizantes);          
        listaDetalleDron[tokenId].autonomia = autonomia;
        listaDetalleDron[tokenId].costeVueloDron = costeVuelo;
        listaDetalleDron[tokenId].m2_por_minuto = m2_por_minuto;
        emit eventmintDron(tokenId,to,address(this));
        super.incrementoIndexToken();
        return tokenId;
        
    }

    function getDatosDron(uint256 idToken) public view returns (uint256 costeVuelo, uint256 autonomia, uint256 m2_por_minuto, uint256 alturamax, uint256 alturamin)
    {
           return ( listaDetalleDron[idToken].costeVueloDron , listaDetalleDron[idToken].autonomia , listaDetalleDron[idToken].m2_por_minuto,  super.getAlturaMaxima(idToken), super.getAlturaMinima(idToken) );
    }

    function getAutonomiaDron(uint256 idToken) public view returns (uint256 autonomia)
    {
           return (listaDetalleDron[idToken].autonomia);
    }

    function getCosteVueloDron(uint256 idToken) public view returns (uint256 costeVuelo)
    {
           return (listaDetalleDron[idToken].costeVueloDron);
    }

    
    function getm2MinutoDron(uint256 idToken) public view returns (uint256 m2porminuto)
    {
           return (listaDetalleDron[idToken].m2_por_minuto);
    }

  
   
    

}