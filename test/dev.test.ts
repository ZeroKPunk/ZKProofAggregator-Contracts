import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { mine, mineUpTo } from "@nomicfoundation/hardhat-network-helpers";
import {
  VerifierMock,
  VerifierMock__factory,
  ZKAVerifier,
  ZKAVerifier__factory,
  ZKAFactory,
  SPVVerifier,
} from "../typechain-types";
import { IZKAFactory } from "../typechain-types/contracts/ZKAFactory";
import { ethers } from "hardhat";
import {
  deploySPVVerifier,
  deployZKAFactory,
  deployZKAVerifier,
  deployZKProofAggregatorImpl,
} from "../scripts/deployment";
import { fetchAllZKAVerifiersMeta, zkpVerify } from "../scripts/interact";
import { expect } from "chai";
import { Signer } from "ethers";
import { get } from "http";

describe("ZKProofAggregator-UnitTest", () => {
  let signers: HardhatEthersSigner[];
  let zkpVerifierMock: VerifierMock;
  let deployer: HardhatEthersSigner;
  let zkaFactory: ZKAFactory;
  let zkaVerifierInstance: ZKAVerifier[];
  let spvVerfier: SPVVerifier;

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
    console.log("zka1:", newZKAVerifier, "innerVerifier:", zkpVerifierAddress);

    const zkpVerifierName2 = "SNARK";
    const url2 = "http://localhost:8001";
    const zkpVerifierAddress2 = await zkpVerifierMock.getAddress();
    const newZKAVerifier2 = await deployZKAVerifier(
      zkaFactory,
      zkpVerifierName2,
      url2,
      deployerAddress,
      zkpVerifierAddress2
    );
    console.log(
      "zka2:",
      newZKAVerifier2,
      "innerVerifier:",
      zkpVerifierAddress2
    );

    zkaVerifierInstance = [
      await getZKAVerifier(deployer, newZKAVerifier),
      await getZKAVerifier(deployer, newZKAVerifier2),
    ];

    spvVerfier = await deploySPVVerifier(deployer);
    await spvVerfier.waitForDeployment();
  });

  it("test all contracts should been deployed", async () => {
    expect((await zkpVerifierMock.getDeployedCode())?.length).gt(2);
    expect((await zkaFactory.getDeployedCode())?.length).gt(2);
  });

  it("create new ZKAVerifier", async () => {
    zkaVerifierInstance.forEach(async (zkaVerifier) => {
      expect((await zkaVerifier.getDeployedCode())?.length).gt(2);

      const zkaMetaJustDeployed: IZKAFactory.VerifierMetaStruct =
        await zkaFactory.metaZKAVerifiers(await zkaVerifier.getAddress());
      expect(zkaMetaJustDeployed.deployTimestamp).gt(0);
    });

    const allZKAVerifiers = await fetchAllZKAVerifiersMeta(zkaFactory);
    console.log("allZKAVerifiers: ", allZKAVerifiers);
  });

  it("test ZKAVerifier with mock proof", async () => {
    // zkaVerifierInstance.forEach(async (zkaVerifier) => {
    for (const zkaVerifier of zkaVerifierInstance) {
      const mockProof = await getMockProof(await zkaVerifier.getAddress());
      console.log("mockProof ", mockProof);
      const { verifyResult, proofKey } = await zkpVerify(
        deployer,
        await zkaVerifier.getAddress(),
        mockProof
      );

      expect(verifyResult).to.be.true;
      const timestampInStorage = await zkaFactory.proofInStorage(proofKey);
      console.log("timestampInStorage: ", timestampInStorage);
      expect(timestampInStorage).to.be.gt(0);
    }
  });

  it("test SPVVerifier", async () => {
    await spvVerfier.setVerifier(await zkpVerifierMock.getAddress());
    const proofMock = await getMockProof(await spvVerfier.getAddress());

    const tx = await spvVerfier.verify(proofMock);
    await tx.wait();
    console.log("spv verifier pass");
  });
});

async function getZKAVerifier(
  signer: Signer,
  ZKAVerifierAddress: string
): Promise<ZKAVerifier> {
  const instance = new ZKAVerifier__factory(signer).attach(ZKAVerifierAddress);
  return instance as ZKAVerifier;
}

async function getMockProof(salt: string): Promise<string> {
  const veiriferMock = await new VerifierMock__factory(
    (
      await ethers.getSigners()
    )[0]
  ).deploy();
  return await veiriferMock.getVerifyCalldata(salt);
}
