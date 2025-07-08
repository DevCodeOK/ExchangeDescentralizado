# ExchangeDescentralizado
Exchange Descentralizado con Pools de Liquidez que intercambie dos tokens ERC-20

# SimpleDEX – Intercambio Descentralizado (DEX)
Este proyecto es un contrato inteligente de un exchange descentralizado (DEX) básico implementado en Solidity. Permite:

Agregar liquidez con dos tokens (TokenA y TokenB)

Retirar liquidez (solo el owner)

Realizar intercambios entre TokenA y TokenB con la fórmula (x + dx) * (y - dy) = x * y

Consultar el precio actual de un token respecto al otro

## Despliegue en Testnet
Red	Dirección del contrato

TokenA
0x9Fe...1a3c3

TokenB
0x497...Db0a0

SimpleDEX
0x6a3...e0413

## Tecnologías utilizadas
Solidity ^0.8.22

OpenZeppelin Contracts

Remix IDE

MetaMask

Sepolia Testnet

Plugin Contract Verification

## Características del contrato
addLiquidity(): Permite a cualquier usuario aportar tokens al pool

removeLiquidity(): Solo el owner puede retirar liquidez

swapAforB() y swapBforA(): Realizan intercambios según reservas

getPrice(): Devuelve el precio estimado de uno de los tokens


## Estructura del proyecto

├── TokenA.sol      // Token ERC20 personalizado

├── TokenB.sol      // Otro token ERC20 personalizado

└── SimpleDEX.sol   // Contrato principal del DEX

## Verificación
Todos los contratos están verificados en Etherscan

## Licencia
Este proyecto está bajo la licencia MIT.

#### Autor
Odalis
