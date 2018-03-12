import contract from 'truffle-contract'
import LoanFactoryContract from '@contracts/LoanFactory.json'
import IpfsQueries from './ipfsQueries'

const LoanFactory = {

  contract: null,

  instance: null,

  init: function () {
    let self = this

    return new Promise(function (resolve, reject) {
      self.contract = contract(LoanFactoryContract)
      self.contract.setProvider(window.web3.currentProvider)

      self.contract.deployed().then(instance => {
        self.instance = instance
        resolve()
      }).catch(err => {
        reject(err)
      })
    })
  },

  loanCount: function () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.loanCount.call(
        {from: window.web3.eth.accounts[0]}
      ).then(loanCount => {
        resolve(loanCount)
      }).catch(err => {
        reject(err)
      })
    })
  },

  getLoanForBorrower: function (address) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.getLoanForBorrower.call(
        address || window.web3.eth.accounts[0]
      ).then(loanAddress => {
        resolve(loanAddress)
      }).catch(err => {
        reject(err)
      })
    })
  },

  loans: function (index) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.loans.call(
        index,
        {from: window.web3.eth.accounts[0]}
      ).then(loanAddress => {
        resolve(loanAddress)
      }).catch(err => {
        reject(err)
      })
    })
  },

  createIpfs: function (name, use) {
    return new Promise((resolve, reject) => {
      IpfsQueries.addNameUseHash(name, use).then(ipfsHash => {
        resolve(ipfsHash)
      }).catch(err => {
        reject(err)
      })
    })
  },

  createLoan: function (loanAmountInEthers, repaymentDurationInDays, name, use) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.create(
        loanAmountInEthers,
        repaymentDurationInDays,
        name,
        use,
        {from: window.web3.eth.accounts[0]}
      ).then(tx => {
        resolve(tx)
      }).catch(err => {
        reject(err)
      })
    })
  },

  create: function (loanAmountInEthers, repaymentDurationInDays, name, use) {
    let self = this

    return new Promise((resolve, reject) => {
      self.createIpfs(name, use).then((file) => {
        const ipfsHash = file[0].path
        resolve(self.createLoan(loanAmountInEthers, repaymentDurationInDays, ipfsHash))
      }).catch(err => {
        reject(err)
      })
    })
  }
}

export default LoanFactory
