// test/Delegation.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

// load compiled artifacts
const Delegate = artifacts.require('Delegate');
const Delegation = artifacts.require('Delegation');
const DelegationAttack = artifacts.require('DelegationAttack');

// start test block
contract('Delegation', function ([ owner, other ]) {

  beforeEach(async function () {
    this.delegate = await Delegate.new(owner, { from: owner });
    this.delegation = await Delegation.new(this.delegate.address, { from: owner });
    this.delegationAttack = await DelegationAttack.new(this.delegation.address, {from: other});
    // check owner initially owns vulnerable contract
    expect(await this.delegate.owner()).to.equal(owner);
    expect(await this.delegation.owner()).to.equal(owner);
  });

  it('test attack: steal ownership from owner to attack contract', async function () {
    await this.delegationAttack.attack({from: other});
    expect(await this.delegation.owner()).to.equal(this.delegationAttack.address);
  });
});
