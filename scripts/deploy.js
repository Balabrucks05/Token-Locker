const {ethers, upgrades} = require('hardhat');

async function main() {
    //Deploy ERC20 token
    // const ERC20Token = await ethers.getContractFactory('ERC20Token');
    // const erc20Token = await ERC20Token.deploy("AOCTOKEN","AOC");
    // // await erc20Token.waitForDeployment();

    // console.log("Erc20 Token deployed to:", await erc20Token.getAddress());

    // //Deploy TokenLocker Contract
    // const TokenLocker = await ethers.getContractFactory('TokenLocker');
    // const tokenLocker = await upgrades.deployProxy(TokenLocker,[],{initializer: 'initialize'});
    // // await tokenLocker.waitForDeployment();

    // console.log("TokenLocker deployed to (Proxy):",await tokenLocker.getAddress());
    
    //Import TokenLockerV2 contracr
    const TokenLockerV2 = await ethers.getContractFactory('TokenLockerV2')

    //Address of the Deployed Proxy contract
    const proxyAddress = "0x04F64f32C4185556397dC4f66B84572C44094812";

    //Upgrade the existing proxy to the new Implementation(TokenLockerV2)
    const upgradedTokenLocker = await upgrades.upgradeProxy(proxyAddress, TokenLockerV2);
    console.log("TokenLocker upgraded to:", await upgradedTokenLocker.getAddress());


    //  // Approve the TokenLocker contract to handle tokens
    //  const approvalAmount = ethers.parseUnits("1000000", 18); // 1000000 tokens
    //  console.log(`Approving TokenLocker to transfer ${approvalAmount.toString()} AOC tokens...`);
    //  const approvalTx = await erc20Token.approve(await tokenLocker.getAddress(), approvalAmount);
    //  await approvalTx.wait();
    //  console.log("TokenLocker approved to handle tokens.");


 }



main().catch((error) => {
    console.error(error);
    process.exit(1);
})