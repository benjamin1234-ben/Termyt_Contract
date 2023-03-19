// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const Termyt = await hre.ethers.getContractFactory("Termyt");
  const termyt = await Termyt.deploy("Termyt", "TMT", "https://moccasin-petite-piranha-265.mypinata.cloud/ipfs/QmaHvLho2mMrkBqHiUnXWvLBkesTShhaNBfBX3bu7hE6Xc/");

  await termyt.deployed();

  console.log(
    `The Termyt contract was deployed to ${termyt.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
