//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

contract Zhouzhe {

    //Get a address balance.
    function getBalance(address account) external view returns (uint256) {
        return account.balance;
    }

    //Get a block hash.
    function getBlockHash(uint blockNumber) external view returns (bytes32) {
        return blockhash(blockNumber);
    }

    //Get last block hash.
    function getLastBlockHash() external view returns (bytes32) {
        return blockhash(block.number - 1);
    }

    //Get current block timestamp.
    function getTimeStamp() external view returns (uint) {
        return block.timestamp;
    }

    //Get current block number.
    function getBlockHeight() external view returns (uint) {
        return block.number;
    }

    //Get current block difficulty.
    function getDifficulty() external view returns (uint) {
        return block.difficulty;
    }

    //Get current block gaslimit.
    function getGasLimit() external view returns (uint) {
        return block.gaslimit;
    }

    //Get current block coinbase account.
    function getCoinBaseCount() external view returns (address payable) {
        return block.coinbase;
    }
}