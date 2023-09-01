const axios = require('axios')

const deal_status = async(cid) =>{
    const dealStatus = await axios.get(`https://calibration.lighthouse.storage/api/deal_status?cid=${cid}`)
    console.log(dealStatus.data)
    console.log("Sample Parsed Object:")
    console.log("Deal ID: " + Number(dealStatus.data.currentActiveDeals[0][0].hex))
    console.log("Miner ID: t0" + Number(dealStatus.data.currentActiveDeals[0][1].hex))
}

deal_status("QmTgLAp2Ze2bv7WV2wnZrvtpR5pKJxZ2vtBxZPwr7rM61a")
