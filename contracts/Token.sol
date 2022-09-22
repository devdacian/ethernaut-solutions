// SPDX-License-Identifier: MIT

// exercise code requires older solc to enable underflow/overflow
// hardhat.config.js already configured with appropriate version
pragma solidity ^0.6.0;

contract Token {

  mapping(address => uint) balances;
  uint public totalSupply;

  constructor(uint _initialSupply) public {
    balances[msg.sender] = totalSupply = _initialSupply;
  }

  function transfer(address _to, uint _value) public returns (bool) {
    require(balances[msg.sender] - _value >= 0);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    return true;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}


// solution used by unit test
// see https://solidity-by-example.org/hacks/overflow/
// all tokens belong to address that creates contract
// user given 20 tokens after contract creation
contract TokenAttack {
   Token token;

  constructor(address _token) public {
    token =  Token(_token);
  }

  function attack() public {
  }
}


// solution used to deploy live to testnet
pragma solidity ^0.6.0;

// vulnerable contract stub with required function
contract TokenLive {
  function transfer(address _to, uint _value) public returns (bool) {}
  function balanceOf(address _owner) public view returns (uint balance) {}
}

// attack contract
contract TokenAttackLive {
  // todo: change this address to your vulnerable contract instance address
  // before deploying this file to testnet via remix
  address TOKEN_ADDRESS = 0xD95d07691c0081e422b529510feb51F554B010c2;

  TokenLive token;

  constructor() public {
    token = TokenLive(TOKEN_ADDRESS);
  }

  function attack() public {
    //token.changeOwner(msg.sender);
  }
}
