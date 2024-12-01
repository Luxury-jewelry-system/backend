const { ethers } = require("hardhat");

async function main() {
    console.log("Deploying DiamondLifecycle Contract...");

    // 获取合约工厂
    const DiamondLifecycle = await ethers.getContractFactory("DiamondLifecycle");

    // 部署合约
    const jewelry = await DiamondLifecycle.deploy();

    // 等待交易确认
    const receipt = await jewelry.deploymentTransaction().wait(); // v6 替代方法

    // 输出合约地址
    console.log("Contract deployed to:", jewelry.target);
    console.log("Deployment Transaction Hash:", receipt.transactionHash);
}

main().catch((error) => {
    console.error("Error deploying contract:", error);
    process.exitCode = 1;
});
