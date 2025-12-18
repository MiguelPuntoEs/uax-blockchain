// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// Ejemplo tomado de Mastering Ethereum

contract Faucet {
    function withdraw(uint256 _withdrawAmount, address payable _to) public {
        require(_withdrawAmount <= 1e4, "El importe ha de ser inferior a 1e4 wei");
        (bool ok, ) = _to.call{value: _withdrawAmount}("");
        require(ok, "ETH transfer failed");
    }

    // Función para recibir Ether, msg.data debe estar vacío
    receive() external payable { }

    // Función fallback cuando msg.data no está vacío
    fallback() external payable { }
}