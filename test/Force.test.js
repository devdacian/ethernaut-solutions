// test/Force.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

// load compiled artifacts
const Force = artifacts.require('Force');
const ForceAttack = artifacts.require('ForceAttack');

// start test block
contract('Force', function ([ owner, other ]) {

  beforeEach(async function () {
    this.force = await Force.new({ from: owner });
    this.forceAttack = await ForceAttack.new(this.force.address, {from: other});
    // check initial contract has no balance
    expect(BN((await ethers.provider.getBalance(this.force.address)).toString())).to.be.bignumber.equal(BN('0'));
  });

  it('test attack: force contract to receive funds via selfdestruct', async function () {
    await this.forceAttack.attack({from: other, value: 1});
    expect(BN((await ethers.provider.getBalance(this.force.address)).toString())).to.be.bignumber.equal(BN('1'));
  });
});
