require("dotenv").config()
const { ethers } = require("ethers")
const dealStatusAbi = require("../../abi/dealStatusAbi")

const callFileDetails = async (cid) => {
  // Provider
  const provider = new ethers.providers.JsonRpcProvider("https://api.calibration.node.glif.io/rpc/v1")

  // Contract object
  const contractAddress = "0x6ec8722e6543fB5976a547434c8644b51e24785b"
  const contract = new ethers.Contract(contractAddress, dealStatusAbi, provider)

  // Call getAllDeals
  let fileInfo = await contract.getAllDeals(ethers.utils.hexlify(ethers.utils.toUtf8Bytes(cid)), {
    gasLimit: 50_000_000,
  })
  console.log(fileInfo)
}

callFileDetails("QmZETJF6NC9p9KkkgczH7SJymhi6HdwvJSv6n2GWdDK4T6")
