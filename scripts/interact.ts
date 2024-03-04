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
  zkProof: string
): Promise<{
  verifyResult: boolean;
  proofKey: string;
}> {
  let verifyResult: boolean = true;
  let proofKey: string = "";
  const zkaVerifier: ZKAVerifier = ZKAVerifier__factory.connect(
    ZKAVerifierAddress,
    signer
  );

  try {
    const tx = await zkaVerifier.zkpVerify(zkProof);
    await tx.wait();
  } catch (error) {
    console.log("error: ", error);
    verifyResult = false;
  }

  try {
    proofKey = await zkaVerifier.fetchProofKey(zkProof);
  } catch (error) {
    console.log("error: ", error);
  }

  return {
    verifyResult,
    proofKey: proofKey,
  };
}
