const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Termyt", function () {
    async function deployTermytFixture () {
        const [owner, otherAccount] = await ethers.getSigners();

        const Termyt = await hre.ethers.getContractFactory("Termyt");
        const termyt = await Termyt.deploy("Termyt", "TMT");

        return { termyt, owner, otherAccount };
    }

    describe("Deployment", function () {

    })
})