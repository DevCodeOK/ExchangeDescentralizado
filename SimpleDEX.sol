// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title SimpleDEX - Exchange descentralizado con fórmula de producto constante
contract SimpleDEX is Ownable {

    // Declaramos las dos variables que representarán los contratos TokenA y TokenB
    IERC20 public tokenA;
    IERC20 public tokenB;

    // Eventos para registrar acciones importantes del contrato
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);
    event LiquidityRemoved(address indexed owner, uint256 amountA, uint256 amountB);
    event TokenSwapped(address indexed user, string direction, uint256 amountIn, uint256 amountOut);

    // Constructor del contrato
    constructor(address _tokenA, address _tokenB) Ownable(msg.sender) {
        // Validamos que las direcciones de los tokens no sean cero
        require(_tokenA != address(0) && _tokenB != address(0), "Token address cannot be zero");
        
        // Asignamos las direcciones a las variables del contrato
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    /// @notice Agrega liquidez al pool (depositar tokens A y B)
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        // Verificamos las cantidades
        require(amountA > 0 && amountB > 0, "Amounts must be > 0");

        // Transferimos los tokens desde el usuario hacia el contrato
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        // Emitimos un evento para registrar la acción
        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

    /// @notice Permite al owner retirar tokens del pool (retirar liquidez)
    function removeLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        // Verificamos que haya suficiente liquidez en el contrato
        require(amountA <= tokenA.balanceOf(address(this)), "No hay suficiente TokenA");
        require(amountB <= tokenB.balanceOf(address(this)), "No hay suficiente TokenB");

        // Enviamos los tokens al dueño del contrato
        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);

        // Emitimos un evento para registrar el retiro
        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

    /// @notice Intercambia TokenA por TokenB usando fórmula x*y=k (producto constante)
    function swapAforB(uint256 amountAIn) external {
        require(amountAIn > 0, "El importe debe ser > 0");

        // Obtenemos las reservas actuales del pool
        uint256 reserveA = tokenA.balanceOf(address(this)); // x
        uint256 reserveB = tokenB.balanceOf(address(this)); // y

        // Calculamos las nuevas reservas simulando el ingreso de dx = amountAIn
        uint256 newReserveA = reserveA + amountAIn; // x + dx

        // Aplicamos la fórmula del producto constante para calcular y - dy
        uint256 newReserveB = (reserveA * reserveB) / newReserveA;

        // Calculamos dy = y - newReserveB, es decir, cuánto TokenB recibirá el usuario
        uint256 amountBOut = reserveB - newReserveB;

        // Verificamos que haya suficiente TokenB disponible
        require(amountBOut <= reserveB, "No hay suficientes TokenB en reserva");

        // Hacemos el intercambio: el usuario envía TokenA, y recibe TokenB
        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        tokenB.transfer(msg.sender, amountBOut);

        // Registramos el swap con un evento
        emit TokenSwapped(msg.sender, "AtoB", amountAIn, amountBOut);
    }

    /// @notice Intercambia TokenB por TokenA usando fórmula x*y=k (producto constante)
    function swapBforA(uint256 amountBIn) external {
        require(amountBIn > 0, "El importe debe ser > 0");

        // Obtenemos las reservas actuales del pool
        uint256 reserveA = tokenA.balanceOf(address(this)); // y
        uint256 reserveB = tokenB.balanceOf(address(this)); // x

        // Simulamos que se agregará dx = amountBIn a TokenB (x + dx)
        uint256 newReserveB = reserveB + amountBIn;

        // Calculamos la nueva reserva de A para mantener constante el producto k
        uint256 newReserveA = (reserveA * reserveB) / newReserveB;

        // Calculamos cuánto TokenA recibirá el usuario (dy = y - newReserveA)
        uint256 amountAOut = reserveA - newReserveA;

        // Verificamos que haya suficiente TokenA disponible
        require(amountAOut <= reserveA, "No hay suficientes TokenA en reserva");

        // Ejecutamos el intercambio: el usuario da TokenB, recibe TokenA
        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        tokenA.transfer(msg.sender, amountAOut);

        // Emitimos evento de intercambio
        emit TokenSwapped(msg.sender, "BtoA", amountBIn, amountAOut);
    }

    /// @notice Devuelve el precio actual de un token respecto al otro
    /// @dev Usa reservaB / reservaA para saber cuántos TokenB vale 1 TokenA (y viceversa)
    function getPrice(address _token) external view returns (uint256) {
        // Obtenemos las reservas del pool
        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));

        // Si el pool está vacío, no se puede calcular precio
        require(reserveA > 0 && reserveB > 0, "Pool Vacio");

        // Si el token consultado es TokenA, devolvemos su precio en TokenB
        if (_token == address(tokenA)) {
            return (reserveB * 1e18) / reserveA;
        } 
        // Si el token consultado es TokenB, devolvemos su precio en TokenA
        else if (_token == address(tokenB)) {
            return (reserveA * 1e18) / reserveB;
        } 
        // Si la dirección no es válida, mostramos error
        else {
            revert("El token no esta en el pool");
        }
    }
}
