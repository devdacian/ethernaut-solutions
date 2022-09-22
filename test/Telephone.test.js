// test/Telephone.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

// load compiled artifacts
const Telephone = artifacts.require('Telephone');
const TelephoneAttack = artifacts.require('TelephoneAttack');

// start test block
contract('Telephone', function ([ owner, other ]) {

  beforeEach(async function () {
    this.telephone = await Telephone.new({ from: owner });
    this.telephoneAttack = await TelephoneAttack.new(this.telephone.address, {from: other});
    // check owner initially owns vulnerable contract
    expect(await this.telephone.owner()).to.equal(owner);
  });

  it('test attack: steal ownership from owner to other', async function () {
    await this.telephoneAttack.attack({from: other});
    expect(await this.telephone.owner()).to.equal(other);
  });
});
