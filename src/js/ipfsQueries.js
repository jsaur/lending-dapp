import IpfsAPI from 'ipfs-api'

class IpfsQueries {
  constructor () {
    this.ipfs = IpfsAPI()
  }

  getHash (hash) {
    return this.ipfs.get(hash)
  }

  addNameUseHash (name, use) {
    // TODO: Discuss 'salt' with team. Has pros & cons
    const ipfsData = JSON.stringify({name: name, use: use, salt: Math.random()})
    const buf = Buffer.from(ipfsData)
    return this.ipfs.add(buf)
  }
}

export default new IpfsQueries()
