import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { mine, mineUpTo } from "@nomicfoundation/hardhat-network-helpers";
import {
  VerifierMock,
  VerifierMock__factory,
  ZKAVerifier,
  ZKAVerifier__factory,
  ZKAFactory,
} from "../typechain-types";
import { IZKAFactory } from "../typechain-types/contracts/ZKAFactory";
import { ethers } from "hardhat";
import {
  deployZKAFactory,
  deployZKAVerifier,
  deployZKProofAggregatorImpl,
} from "../scripts/deployment";
import { zkpVerify } from "../scripts/interact";
import { expect } from "chai";
import { Signer } from "ethers";

describe("ZKProofAggregator-UnitTest", () => {
  let signers: HardhatEthersSigner[];
  let zkpVerifierMock: VerifierMock;
  let deployer: HardhatEthersSigner;
  let zkaFactory: ZKAFactory;
  let zkaVerifierInstance: ZKAVerifier;

  before(async () => {
    signers = await ethers.getSigners();
    deployer = signers[0];

    zkpVerifierMock = await new VerifierMock__factory(deployer).deploy();
    const zkpVerifierImplAddress = await deployZKProofAggregatorImpl(deployer);
    zkaFactory = await deployZKAFactory(deployer, zkpVerifierImplAddress);

    const zkpVerifierName = "PLONKY2";
    const url = "http://localhost:3000";
    const deployerAddress = await deployer.getAddress();
    const zkpVerifierAddress = await zkpVerifierMock.getAddress();

    const newZKAVerifier = await deployZKAVerifier(
      zkaFactory,
      zkpVerifierName,
      url,
      deployerAddress,
      zkpVerifierAddress
    );

    zkaVerifierInstance = await getZKAVerifier(deployer, newZKAVerifier);
  });

  it("test all contracts should been deployed", async () => {
    expect((await zkpVerifierMock.getDeployedCode())?.length).gt(2);
    expect((await zkaFactory.getDeployedCode())?.length).gt(2);
  });

  it("create new ZKAVerifier", async () => {
    expect((await zkaVerifierInstance.getDeployedCode())?.length).gt(2);

    const zkaMetaJustDeployed: IZKAFactory.VerifierMetaStruct =
      await zkaFactory.metaZKAVerifiers(await zkaVerifierInstance.getAddress());
    console.log("zkaMetaJustDeployed: ", zkaMetaJustDeployed);

    const allZKAVerifiers = await zkaFactory.fetchAllZKAVerifiers();
    console.log("allZKAVerifiers: ", allZKAVerifiers);
  });

  it("test ZKAVerifier with mock proof", async () => {
    const mockProof = await getMockProof();
    const { verifyResult, proofKey, saveTimestamp } = await zkpVerify(
      deployer,
      await zkaVerifierInstance.getAddress(),
      zkaFactory,
      mockProof
    );
    expect(verifyResult).to.be.true;
    const timestampInStorage = await zkaFactory.proofInStorage(proofKey);
    expect(timestampInStorage).to.equal(saveTimestamp);
  });
});

async function getZKAVerifier(
  signer: Signer,
  ZKAVerifierAddress: string
): Promise<ZKAVerifier> {
  const instance = new ZKAVerifier__factory(signer).attach(ZKAVerifierAddress);
  return instance as ZKAVerifier;
}

async function getMockProof(): Promise<string> {
  const veiriferMock = await new VerifierMock__factory(
    (
      await ethers.getSigners()
    )[0]
  ).deploy();
  return await veiriferMock.getVerifyCalldata();
}
