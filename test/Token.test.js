// test/Token.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

// load compiled artifacts
const Token = artifacts.require('Token');
const TokenAttack = artifacts.require('TokenAttack');

// start test block
contract('Token', function ([ owner, other ]) {
  const initialSupply = BN('21000000');
  const initialUserAlloc = BN('20');

  beforeEach(async function () {
    this.vulnContract   = await Token.new(initialSupply ,{ from: owner });
    this.attackContract = await TokenAttack.new(this.vulnContract.address, {from: other});
    // check owner initially owns all tokens
    expect(await this.vulnContract.balanceOf(owner)).to.be.bignumber.equal(initialSupply);
    // transfer intial user allocated tokens to attack contract & check balances
    await this.vulnContract.transfer(this.attackContract.address, initialUserAlloc, { from: owner });
    expect(await this.vulnContract.balanceOf(owner)).to.be.bignumber.equal(BN(initialSupply-initialUserAlloc));
    expect(await this.vulnContract.balanceOf(this.attackContract.address)).to.be.bignumber.equal(initialUserAlloc);
  });

  it('test attack: steal all tokens from owner to other', async function () {
    await this.attackContract.attack({from: other});
    expect(await this.vulnContract.balanceOf(other)).to.be.bignumber.equal(BN(initialSupply));
  });
});
