import contract from 'truffle-contract'
import LoanFactoryContract from '@contracts/LoanFactory.json'

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
      self.instance.exists.call(
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
      self.instance.get.call(
        address || window.web3.eth.defaultAccount,
        {from: window.web3.eth.accounts[0]}
      ).then(loanAddress => {
        resolve(loanAddress)
      }).catch(err => {
        reject(err)
      })
    })
  }

  create: function (name) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.create(
        loanAmountInEthers,
        repaymentDurationInDays
        {from: window.web3.eth.accounts[0]}
      ).then(tx => {
        resolve(tx)
      }).catch(err => {
        reject(err)
      })
    })
  }
}

export default LoanFactory
