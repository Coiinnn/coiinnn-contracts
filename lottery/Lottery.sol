// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Lottery {

    address private owner;
    uint private randNonce = 0;
    uint private modulus = 10;
    uint16 private winPercent;

    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    event StartGame(address player, uint256 amount);
    event LoseGame(address player, uint256 amount, uint number);
    event WinGame(address player, uint256 amount, uint number);
    event ChangeWinPercent(address player, uint16 newWinPercent);
    event TopUpBalance(address player, uint256 amount);

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        winPercent = 5;
        emit OwnerSet(address(0), owner);
    }

    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    function changeWinPercent(uint16 newWinPercent) external isOwner {
        require(newWinPercent < 10 && newWinPercent > 0, "New win percent should be in ranhe 1% - 99%");
        emit ChangeWinPercent(msg.sender, newWinPercent);
        winPercent = newWinPercent;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function getWinPercent() external view returns (uint16) {
        return winPercent * 10;
    }

    function topUpBalance() external payable {
        emit TopUpBalance(msg.sender, msg.value);
    }


    function play() external payable {
        require(msg.value > 0, "You cannot play with zero amount!");
        require(msg.value * 2 <= address(this).balance, "Not enough balance in storage.");
        emit StartGame(msg.sender, msg.value);
        uint randomValue = random();
        if (randomValue > winPercent) {
            emit LoseGame(msg.sender, msg.value, randomValue);
        } else {
            emit WinGame(msg.sender, msg.value, randomValue);
            (bool os, ) = payable(msg.sender).call{value: msg.value * 2}("");
            require(os);
        }

    }

    function random() private returns (uint) {
        randNonce++;
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % modulus + 1;
    }

}