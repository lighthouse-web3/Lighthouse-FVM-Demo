const axios = require('axios')

const getData = async() =>{
    const cid = 'QmS7Do1mDZNBJAVyE8N9r6wYMdg27LiSj5W9mmm9TZoeWp'
    const podsi = await axios.get(`https://api.lighthouse.storage/api/lighthouse/get_proof?cid=${cid}&network=testnet`)
    console.log(podsi.data)
}

getData()
