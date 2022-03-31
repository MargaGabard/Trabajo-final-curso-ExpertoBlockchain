// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "./DronTokenColeccion.sol";
import "./ParcelaTokenColeccion.sol";
import "./FumToken.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


contract FumigaSA is IERC721Receiver , Ownable {

  constructor()  {

     contract_DronToken = address(new DronTokenColeccion("D","Drones"));
     contract_ParcelaToken = address(new ParcelaTokenColeccion("P","Parcelas"));
  }
  
  //Address donde se guardan las direcciones de los contratosERC721 de Drones y Parcelas
  address public immutable  contract_DronToken;
  address public immutable contract_ParcelaToken;
 
  
  //Estados de una contratación de fumigación
    enum estadoContratacion {Pendiente, Activa, Ejecutada}

  struct fumigacion{
    uint256 idParcela;
    uint256 idPestizida;
    estadoContratacion estado;
  }


  //Relación de fumigaciones contratadas, por Dron
mapping(uint256  => fumigacion) public listaFumigaciones;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////Alta de un nuevo Dron ///////////////////////////////////////////// //////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  function crearDron(address to, uint256 alturaMax, uint256 alturaMin, uint256 costeVuelo, uint256 autonomia, uint256 m2_por_minuto, uint256[] memory fertilizantes) external returns(uint256){  

        require(alturaMax > alturaMin, "Valores alturas incorrectos");
        DronTokenColeccion _dronToken = DronTokenColeccion(contract_DronToken);
        uint256 tokenId = _dronToken.mint(to, alturaMax, alturaMin, costeVuelo, autonomia,m2_por_minuto,fertilizantes);
        return tokenId;
  }
  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////Alta de una nueva Parcela ////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  function crearParcela(address to, uint256 alturaMax, uint256 alturaMin, uint256 m2superfice, uint256[] memory fertilizantes) external returns(uint256 result){  
        require(alturaMax > alturaMin, "Valores alturas incorrectos");
        ParcelaTokenColeccion _parcelaToken = ParcelaTokenColeccion(contract_ParcelaToken);
     uint256 tokenId = _parcelaToken.mint(to, alturaMax, alturaMin, m2superfice, fertilizantes);
       return tokenId;
  }

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////Disponiblidad del Dron ////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function dronDisponible (uint256 idDron) public returns (bool result)
{

    if (listaFumigaciones[idDron].estado!= estadoContratacion.Activa) 
    {
      return true;

    }else
    return false;

}


event contratarFumigacionLog(uint256  idDron, uint256 idParcela, uint256 idPestizida, address to, bool result);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////Asignar la contratación de un dron para fumigar una parcela //////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function contratarFumigacion (uint256 idDron, uint256 idParcela, uint256 idPestizida) external returns (bool result)
{
    //Mirar si el dron esta disponible  
    require (dronDisponible(idDron), "Dron no disponible");
    require (compatibilidadDronParcela(idDron,idParcela), "Dron no compatible");
    
    
  //Agrego la información a la relacion de dron-contratacion
    listaFumigaciones[idDron].idParcela= idParcela;
    listaFumigaciones[idDron].estado= estadoContratacion.Activa; 
    listaFumigaciones[idDron].idPestizida= idPestizida;   
    emit contratarFumigacionLog(idDron,idParcela, idPestizida, msg.sender, true);
    return true;
    
    }
     

event ParcelaFumigadaLog(uint256  idDron, uint256 idParcela, estadoContratacion estado);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////Fumigación de la parcela//////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function fumigacionParcela (uint256 idDronFumigar, uint256 idParcelaFumigar) external onlyOwner returns (bool result)
{

    //Mirar si el dron esta asignado a esa parcela y esta activa la contratación 
    require(listaFumigaciones[idDronFumigar].idParcela== idParcelaFumigar, "Dron no esta asignado a parcela");
    require(listaFumigaciones[idDronFumigar].estado== estadoContratacion.Activa, "Dron-Parcela no activa");

    
  //Se asume en este punto que la fumigación se ha ejecutado ya que es inmediata y se marca como tal
    listaFumigaciones[idDronFumigar].estado= estadoContratacion.Ejecutada;  
    emit ParcelaFumigadaLog(idDronFumigar,idParcelaFumigar,listaFumigaciones[idDronFumigar].estado);
    return true;
    
    }
     

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////çComprueba que el dron es compatible con la parcela y si lo es devulve true //////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function compatibilidadDronParcela (uint256 idDron, uint256 idParcela) public view returns (bool result)
{
   
    DronTokenColeccion _DronToken = DronTokenColeccion(contract_DronToken);
    ParcelaTokenColeccion _ParcelaToken = ParcelaTokenColeccion(contract_ParcelaToken);


    if (_DronToken.getAlturaMinima(idDron) > _ParcelaToken.getAlturaMaxima(idParcela))
         return false;

    if (_ParcelaToken.getAlturaMinima(idParcela) > _DronToken.getAlturaMaxima(idDron))
         return false;

    uint256[] memory pestizidasDron =  _DronToken.getListaPesticidas(idDron);
    uint256[] memory pestizidasParcela =  _ParcelaToken.getListaPesticidas(idParcela);

    bool tienePestizida;

    //Si la parcela requiere mas pestizidas de los que soporta el Dron no son compatibles    
    if (pestizidasParcela.length > pestizidasDron.length){
       return false;
    }

    //Si la parcela no requiere de ningun pestizida en particular
    if (pestizidasParcela.length==0){
      return true;
    }

    for (uint256 i = 0; i < pestizidasParcela.length ; i++) {
              tienePestizida=false;
              for (uint256 j = 0; j < pestizidasDron.length ; j++) {
                    if (pestizidasParcela[i] == pestizidasDron[j] ) {
                      tienePestizida=true;
                    }
               }
               if (tienePestizida==false) 
               {
                 return false;
              }
      }
         
     return true;
    
}


event costeFumiLog (uint256 costevuelo, uint256 recargas, uint256 autonomia, uint256 minutosvuelo);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////Calcula el coste de fumigación de un Dron en una Parcela//////////// //////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function costeFumigacionDronParcela (uint256 idDron, uint256 idParcela) external  returns (uint256 result)
{
    
    uint256 minutosVueloDron;
    
    DronTokenColeccion _DronToken = DronTokenColeccion(contract_DronToken);
    ParcelaTokenColeccion _ParcelaToken = ParcelaTokenColeccion(contract_ParcelaToken);
 
    //minutosVueloDron=10;
    minutosVueloDron= (_ParcelaToken.getSuperficieParcela(idParcela) / _DronToken.getm2MinutoDron(idDron));

    emit costeFumiLog (_DronToken.getCosteVueloDron(idDron), 1 ,_DronToken.getAutonomiaDron(idDron), minutosVueloDron);
    if (minutosVueloDron <= _DronToken.getAutonomiaDron(idDron))
        return (_DronToken.getCosteVueloDron(idDron));
    
    
    uint256 recargasDron=  (minutosVueloDron / _DronToken.getAutonomiaDron(idDron));
    emit costeFumiLog(_DronToken.getCosteVueloDron(idDron), 1 ,_DronToken.getAutonomiaDron(idDron), minutosVueloDron);

    return (_DronToken.getCosteVueloDron(idDron) * recargasDron);
        
}
event situacion(uint256 parcela, uint256 estado);
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function situacionDron(uint256 idDron)  external  returns (uint256 IdParcela, uint256  idEstado, uint256 pestizida)
{
    uint256 idParcela_ = 0;
    uint256 idEstado_;
    uint256 pestizidas_;
    
    //Si esta asignado el Dron a una parcela (o lo ha estado), recupero sus valores 
    if (listaFumigaciones[idDron].idParcela != 0) {
        idParcela_=listaFumigaciones[idDron].idParcela;
        idEstado_=uint256(listaFumigaciones[idDron].estado);
        pestizidas_ = listaFumigaciones[idDron].idPestizida;
    }
    emit situacion(idParcela_,idEstado_);
  
    return (idParcela_,idEstado_,pestizidas_);
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////GET's para los datos de los Drones y las Parcelas///////////////////// //////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function datosDron(uint256 idDron)  external view returns (uint256 costeVuelo, uint256 autonomia, uint256 m2_por_minuto, uint256 alturamax, uint256 alturamin)
{
    DronTokenColeccion _DronToken = DronTokenColeccion(contract_DronToken);
    
    return (_DronToken.getDatosDron(idDron));
}

function datosParcela(uint256 idParcela) external view returns (uint256 m2superfice, uint256 alturamax, uint256 alturamin, address owner_parcela)
{
      ParcelaTokenColeccion _ParcelaToken = ParcelaTokenColeccion(contract_ParcelaToken);
      return (_ParcelaToken.getDatosParcela(idParcela));

}

function getListaPestizidassDron(uint256 idToken) external view returns(uint256[] memory pestizidas)  {
         DronTokenColeccion _DronToken = DronTokenColeccion(contract_DronToken);
         return (_DronToken.getListaPesticidas(idToken));

}

function getListaPestizidassParcela(uint256 idToken) external view returns(uint256[] memory pestizidas)  {
        ParcelaTokenColeccion _ParcelaToken = ParcelaTokenColeccion(contract_ParcelaToken);
        return (_ParcelaToken.getListaPesticidas(idToken));

}

function getTotalDrones() external view returns(uint256 numTotalDrones)  {
         DronTokenColeccion _DronToken = DronTokenColeccion(contract_DronToken);
         return (_DronToken.getlastTokenIndex());

}

function getTotalParcelas() external view returns(uint256 numTotalParcelas)  {
        ParcelaTokenColeccion _ParcelaToken = ParcelaTokenColeccion(contract_ParcelaToken);
         return (_ParcelaToken.getlastTokenIndex());

}


function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    override public returns (bytes4)  {
        return 0x150b7a02;
    }


function listParcelasPropietario(address owner) external view returns (uint[] memory) {


        ParcelaTokenColeccion _ParcelaToken = ParcelaTokenColeccion(contract_ParcelaToken);
        uint256 balance =_ParcelaToken.balanceOf(owner);

        uint256[] memory tokens = new uint256[](balance);

        for (uint256 i=0; i<balance; i++) {
            tokens[i] = (_ParcelaToken.tokenOfOwnerByIndex(owner, i));
        }

        return tokens;
    }

}

