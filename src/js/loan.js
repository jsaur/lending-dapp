import contract from 'truffle-contract'
import LoanContract from '@contracts/LoanContract.json'
import IpfsQueries from './ipfsQueries'

// This still isn't quite right, but I want a class not a const
// to enable multiple loan contracts for each loan address
class Loan {

  constructor () {
    return this
  }

  init (address) {
    let self = this

    return new Promise(function (resolve, reject) {
      self.contract = contract(LoanContract)
      self.contract.setProvider(window.web3.currentProvider)

      self.contract.at(address).then(instance => {
        self.instance = instance
        resolve()
      }).catch(err => {
        reject(err)
      })
    })
  }

  loanAmount () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.loanAmount.call().then(loanAmount => {
        resolve(parseFloat(window.web3.fromWei(loanAmount)))
      }).catch(err => {
        reject(err)
      })
    })
  }

  amountRaised () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.amountRaised.call().then(amountRaised => {
        resolve(parseFloat(window.web3.fromWei(amountRaised)))
      }).catch(err => {
        reject(err)
      })
    })
  }

  amountRepaid () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.amountRepaid.call().then(amountRepaid => {
        resolve(parseFloat(window.web3.fromWei(amountRepaid)))
      }).catch(err => {
        reject(err)
      })
    })
  }

  ipfsHash () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.ipfsHash.call().then(ipfsHash => {
        resolve(ipfsHash)
      }).catch(err => {
        reject(err)
      })
    })
  }

  parseIpfsInfo (ipfsInfo) {
    const ipfsContent = ipfsInfo[0].content
    return JSON.parse(ipfsContent)
  }

  ipfsInfo () {
    let self = this

    return new Promise((resolve, reject) => {
      return self.ipfsHash().then((hash) => {
        return IpfsQueries.getHash(hash).then(ipfsInfo => {
          resolve(self.parseIpfsInfo(ipfsInfo))
        })
      }).catch(err => {
        reject(err)
      })
    })
  }

  currentState () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.currentState.call().then(currentState => {
        let states = ['raising', 'funded', 'repaying', 'repaid', 'expired']
        resolve(states[currentState])
      }).catch(err => {
        reject(err)
      })
    })
  }

  repaymentDuration () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.repaymentDuration.call().then(repaymentDuration => {
        resolve(parseFloat(repaymentDuration))
      }).catch(err => {
        reject(err)
      })
    })
  }

  expectedLastRepayment () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.repaymentDeadline.call().then(expectedLastRepayment => {
        resolve(new Date(expectedLastRepayment * 1000))
      }).catch(err => {
        reject(err)
      })
    })
  }

  borrowerAddress () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.borrowerAddress.call().then(borrowerAddress => {
        resolve(borrowerAddress)
      }).catch(err => {
        reject(err)
      })
    })
  }

  lenderAccounts (address) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.lenderAccounts.call(
        address || window.web3.eth.accounts[0]
      ).then(lenderAccount => {
        resolve({
          amountLent: parseFloat(window.web3.fromWei(lenderAccount[0])),
          amountRepaid: parseFloat(window.web3.fromWei(lenderAccount[1])),
          amountWithdrawn: parseFloat(window.web3.fromWei(lenderAccount[2]))
        })
      }).catch(err => {
        reject(err)
      })
    })
  }

  amountLenderCanWithdraw (address) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.amountLenderCanWithdraw.call(
        address || window.web3.eth.accounts[0]
      ).then(amountLenderCanWithdraw => {
        resolve(parseFloat(window.web3.fromWei(amountLenderCanWithdraw)))
      }).catch(err => {
        reject(err)
      })
    })
  }

  lend (amount) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.lend({
        from: window.web3.eth.accounts[0],
        value: window.web3.toWei(amount, 'ether')
      }).then(tx => {
        resolve(tx)
      }).catch(err => {
        reject(err)
      })
    })
  }

  repay (amount) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.repay({
        from: window.web3.eth.accounts[0],
        value: window.web3.toWei(amount, 'ether')
      }).then(tx => {
        resolve(tx)
      }).catch(err => {
        reject(err)
      })
    })
  }

  borrowerWithdraw () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.borrowerWithdraw({
        from: window.web3.eth.accounts[0]
      }).then(tx => {
        resolve(tx)
      }).catch(err => {
        reject(err)
      })
    })
  }

  lenderWithdraw () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.lenderWithdraw({
        from: window.web3.eth.accounts[0]
      }).then(tx => {
        resolve(tx)
      }).catch(err => {
        reject(err)
      })
    })
  }
}

export default new Loan()
