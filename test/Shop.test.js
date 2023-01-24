// test/Privacy.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { ethers } = require('hardhat');

// load compiled artifacts
const Shop       = artifacts.require('Shop');
const ShopAttack = artifacts.require('ShopAttack');

// start test block
contract('Shop', function ([ owner, other ]) {

  beforeEach(async function () {
    this.vulnContract   = await Shop.new(owner, { from: owner });
    this.attackContract = await ShopAttack.new(this.vulnContract.address, {from: other});

    expect(await this.vulnContract.isSold()).to.be.false;
  });

  it('test attack: buy item for free', async function () {
    // call the attack contract
    await this.attackContract.attack();

    // check that item is sold for $0 !
    expect(await this.vulnContract.isSold()).to.be.true;
    expect(await this.vulnContract.price()).to.be.bignumber.equal(BN("0"));
  });
});
