require("dotenv").config();
const { ethers } = require("ethers");
const aggregatorAbi = require("../abi/aggregatorABI");

const submit = async () => {
  try {
    console.log("Transaction execution started...");
    const provider = new ethers.providers.JsonRpcProvider(
      "https://api.calibration.node.glif.io/rpc/v1"
    );
    const privateKey = process.env.PRIVATE_KEY; //wallet private key
    const signer = new ethers.Wallet(privateKey, provider);

    const contractAddress = "0x201c21E051D25E4F5F8B3e40Fb019cdeB26301aC";

    const contract = new ethers.Contract(
      contractAddress,
      aggregatorAbi,
      signer
    );

    // Follow this documentation (https://docs.lighthouse.storage/lighthouse-1/lighthouse-sdk/code-examples/nodejs-backend/nodejs) to upload file via Lighthouse SDK
    // Transaction details
    const data_url =
      "https://gateway.lighthouse.storage/ipfs/QmQvQwY42QuukKKWB52qtxMQHVNFM6kjz4Pq3sQwN5f7xY";
    const fileLinkBytes = ethers.utils.hexlify(
      ethers.utils.toUtf8Bytes(data_url)
    );

    // order- file_url
    const submit = await contract.submit(fileLinkBytes, {
      gasLimit: 50_000_000,
    });

    const response = await submit.wait();
    console.log("transaction done");

    const eventData = response.events[0].args;
    // Assuming there is only one event in the response, you can access it like this:

    // Assuming the event has three parameters: bytes, uint256, and address
    const uint256Data = eventData[0];
    const fileLinkHex = eventData[1];
    const fileLinkByte = ethers.utils.arrayify(fileLinkHex);
    const addressData = eventData[2];

    // Now you can work with the event data as needed
    console.log("File Link", ethers.utils.toUtf8String(fileLinkByte));
    console.log("Transaction Id:", uint256Data);
    console.log("Transaction Id in Number:", Number(uint256Data));
    console.log("User Address:", addressData);
  } catch (error) {
    console.log(error.message);
  }
};

submit();
