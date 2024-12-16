const {ethers} = require('hardhat');

async function main() {
    //Deploy ERC20 token
    const ERC20Token = await ethers.getContractFactory('ERC20Token');
    const erc20Token = await ERC20Token.deploy("AOCTOKEN","AOC");
    await erc20Token.deployed();

    console.log("Erc20 Token deployed to:", erc20Token.address);

    //Deploy TokenLocker Contract
    const TokenLocker = await ethers.getContractFactory('TokenLocker');
    const tokenLocker = await TokenLocker.deploy();
    await tokenLocker.deployed();

    console.log("TokenLocker deployed to:", tokenLocker.address);


     // Approve the TokenLocker contract to handle tokens
     const approvalAmount = ethers.utils.parseUnits("1000000", 18); // 1000000 tokens
     console.log(`Approving TokenLocker to transfer ${approvalAmount.toString()} AOC tokens...`);
     const approvalTx = await erc20Token.approve(tokenLocker.address, approvalAmount);
     await approvalTx.wait();
     console.log("TokenLocker approved to handle tokens.");
 }


main().catch((error) => {
    console.error(error);
    process.exit(1);
})