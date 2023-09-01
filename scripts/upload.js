require("dotenv").config()
const lighthouse = require('@lighthouse-web3/sdk')

const uploadFile = async() =>{
  const path = "C:/Users/ravis/Desktop/filecoin code ex/raas-code-examples/testFile/adamsfamily.jpg"; // Give path to the file
  
  const apiKey = process.env.PRIVATE_KEY; //generate from https://files.lighthouse.storage/ or cli (lighthouse-web3 api-key --new)
  const dealParam = {
    "num_copies": 1, // max 3
    "repair_threshold": null, // default 10 days
    "renew_threshold": null, //2880 epoch per day, default 28800, min 240(2 hours)
    "miner": ["t017840"], //user miners
    "network": 'calibration'
  }
  // Both file and folder supported by upload function
  const response = await lighthouse.upload(path, apiKey, false, dealParam);
  console.log(response);
  console.log("Visit at: https://gateway.lighthouse.storage/ipfs/" + response.data.Hash);
}

uploadFile()

// Other testnet miners
// t017819
// t017387
// t017840
// t01491