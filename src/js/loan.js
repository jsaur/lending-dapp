import contract from 'truffle-contract'
import LoanContract from '@contracts/LoanContract.json'

const Loan = {

  contract: null,

  instance: null,

  init: function (address) {
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
  },

  loanAmount: function () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.loanAmount.call().then(loanAmount => {
        resolve(window.web3.fromWei(loanAmount))
      }).catch(err => {
        reject(err)
      })
    })
  }
}

export default Loan
