// test/GatekeeperThree.test.js

// load dependencies
const { expect } = require('chai');

// import utils from test helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

// load compiled artifacts
const GatekeeperThree = artifacts.require('GatekeeperThree');
const GatekeeperThreeAttack = artifacts.require('GatekeeperThreeAttack');

// start test block
contract('GatekeeperThree', function ([ owner, other ]) {

  beforeEach(async function () {
    this.vulnContract   = await GatekeeperThree.new({ from: owner });
    this.attackContract = await GatekeeperThreeAttack.new(this.vulnContract.address, {from: other});
    // verify initial state
    expect(await this.vulnContract.entrant).to.not.equal(other);
  });

  it('test attack: bypass gates to become entrant', async function () {    
    // fund attack contract to bypass gateThree
    const SEND_AMOUNT        = "0.002";
    const SEND_AMOUNT_BN_STR = (ethers.utils.parseEther(SEND_AMOUNT)).toString();

    const sendTx = {
        to: this.attackContract.address
       ,value: ethers.utils.parseEther(SEND_AMOUNT)
    };

    const sendReceipt = await (await ethers.getSigner(other)).sendTransaction(sendTx);
    expect(sendReceipt.status == 1);

    // verify updated attack contract balance
    const afterSendContractBalance = (await ethers.provider.getBalance(this.attackContract.address)).toString();
    expect(afterSendContractBalance).to.equal(SEND_AMOUNT_BN_STR);
    
    await this.attackContract.attack({from: other});
    expect(await this.vulnContract.entrant()).to.equal(other);
  });
});
