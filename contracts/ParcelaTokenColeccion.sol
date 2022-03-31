// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "./FumiTokenColeccion.sol";

//Token de parcelas
contract ParcelaTokenColeccion is  FumiTokenColeccion  {

struct datosParcela {
    uint256 m2superfice;
}

//Relación de idtoken (parcela) con la información de detalle de cada una
mapping(uint256 => datosParcela) listaDetalleParcela;

    constructor(string memory name, string memory symbol) FumiTokenColeccion (name,symbol)  {}

    //Evento que se genera cuando se crea una nueva parcela
   event eventmintParcela (uint256 tokenId, address to);
   
   //Función para crear una nueva parcela
   function mint(address to, uint256 alturaMax, uint256 alturaMin, uint256 m2superfice, uint256[] memory fertilizantes)  public returns (uint256 result)     {
  
        uint256 tokenId = super.mint(to, alturaMax, alturaMin, fertilizantes);          
        listaDetalleParcela[tokenId].m2superfice =  m2superfice;
        emit eventmintParcela(tokenId,to);
        super.incrementoIndexToken();
        return tokenId;
      
    }

    function getDatosParcela(uint256 idToken) public view returns (uint256 m2superfice, uint256 alturaMax, uint256 alturaMin, address owner)
    {     

        return ( listaDetalleParcela[idToken].m2superfice, super.getAlturaMaxima(idToken), super.getAlturaMinima(idToken), super.ownerOf(idToken));
         
    }

     function getSuperficieParcela(uint256 idToken) public view returns (uint256 m2superfice)
    {     
            return (listaDetalleParcela[idToken].m2superfice);
    }


    

}