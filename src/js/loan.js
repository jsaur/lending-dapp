import contract from 'truffle-contract'
import LoanContract from '@contracts/LoanContract.json'

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
        resolve(window.web3.fromWei(loanAmount))
      }).catch(err => {
        reject(err)
      })
    })
  }

  name () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.name.call().then(name => {
        resolve(name)
      }).catch(err => {
        reject(err)
      })
    })
  }
}

export default new Loan()
