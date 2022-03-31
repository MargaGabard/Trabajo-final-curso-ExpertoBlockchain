// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "./Ownable.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract FumiTokenColeccion is  ERC721, ERC721Enumerable, Ownable  {

    uint256 public lastTokenIndex;

   //Estructura con la información común 
   struct comunToken {
       uint256 alturaMax;
       uint256 alturaMin;
       uint256[] listaPestizidas;
    }
  
  // Relacion de id token con sus correspondientes datos comunes
   mapping(uint=> comunToken) public listaComunTokens;

   // Relación id token con los fertilizantes que soporta/requiere
   mapping (uint256 => uint256) public listaFertilizantes; 

   constructor(string memory name, string memory symbol)  ERC721(name,  symbol) Ownable() {     
   }

   event supermint (uint256 tokenId, address dir);

   function incrementoIndexToken() public {
       lastTokenIndex = lastTokenIndex + 1;
   }

    function getlastTokenIndex() public view returns (uint256 numTotalTokens)
    {
           return lastTokenIndex;
    }
   
   function mint(address to, uint256 alturaMax, uint256 alturaMin, uint256[] memory pestizidas) public  returns(uint256)   {
  
        _safeMint(to,lastTokenIndex+1);
        listaComunTokens[lastTokenIndex+1].alturaMax =  alturaMax;
        listaComunTokens[lastTokenIndex+1].alturaMin =  alturaMin;
        
        for(uint256 i=0; i< pestizidas.length; i++){      
            listaComunTokens[lastTokenIndex+1].listaPestizidas.push(pestizidas[i]);
        } 
          
         return lastTokenIndex + 1;
    }

    function getDatosComunes(uint256 idToken) public view returns(uint256 alturaMax, uint256 alturaMin, uint256[] memory pestizidas)   {               
        return (listaComunTokens[idToken].alturaMax,listaComunTokens[idToken].alturaMin,listaComunTokens[idToken].listaPestizidas);
    }

    function getAlturaMaxima(uint256 idToken) public view returns(uint256 alturaMax)  {
        return (listaComunTokens[idToken].alturaMax);
    }

    function getAlturaMinima(uint256 idToken) public view returns(uint256 alturaMinima)  {
        return (listaComunTokens[idToken].alturaMin);
    }

    function getListaPesticidas(uint256 idToken) public view returns(uint256[] memory pestizidas)  {
        return (listaComunTokens[idToken].listaPestizidas);
    }


function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    

}