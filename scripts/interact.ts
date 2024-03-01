import {
  ZKAVerifier,
  ZKAVerifier__factory,
  ZKAFactory,
  ZKAFactory__factory,
} from "../typechain-types";
import { Signer } from "ethers";
import { deployZKAVerifier } from "./deployment";

export async function zkpVerify(
  signer: Signer,
  ZKAVerifierAddress: string,
  zkaFactory: ZKAFactory,
  zkProof: string
): Promise<{
  verifyResult: boolean;
  proofKey: string;
  saveTimestamp: BigInt;
}> {
  let verifyResult: boolean = true;
  const zkaVerifier: ZKAVerifier = ZKAVerifier__factory.connect(
    ZKAVerifierAddress,
    signer
  );
  const filter = zkaFactory.filters.proofToStorageInfo;
  try {
    const tx = await zkaVerifier.zkpVerify(zkProof);
    await tx.wait();
  } catch (error) {
    console.log("error: ", error);
    verifyResult = false;
  }

  const events = await zkaFactory.queryFilter(filter);

  return {
    verifyResult: verifyResult,
    proofKey: events[0].args?._proofKey,
    saveTimestamp: events[0].args?._saveTimestamp,
  };
}
