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
  let proofKey: string = "";
  let saveTimestamp: BigInt = 0n;

  const contract = new ZKAFactory__factory(signer).attach(
    await zkaFactory.getAddress()
  );

  const zkaVerifier: ZKAVerifier = ZKAVerifier__factory.connect(
    ZKAVerifierAddress,
    signer
  );

  // const filter = zkaFactory.filters.proofToStorageInfo;
  contract.once(
    "proofToStorageInfo",
    (_proofKey: string, _saveTimestamp: BigInt) => {
      proofKey = _proofKey;
      saveTimestamp = _saveTimestamp;
      console.log("catch event proofKey", proofKey, "saveTimestamp", saveTimestamp);

    }
  );

  try {
    const tx = await zkaVerifier.zkpVerify(zkProof);
    await tx.wait();
  } catch (error) {
    console.log("error: ", error);
    verifyResult = false;
  }

  // const events = await zkaFactory.queryFilter(filter);
  if (!proofKey) {
    throw new Error("No event found");
  }
  // contract.removeAllListeners();
  return {
    verifyResult: verifyResult,
    proofKey: proofKey,
    saveTimestamp: saveTimestamp,
  };
}
