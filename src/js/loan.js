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

  amountRaised () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.amountRaised.call().then(amountRaised => {
        resolve(window.web3.fromWei(amountRaised))
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

  repaymentDuration () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.repaymentDuration.call().then(repaymentDuration => {
        resolve(repaymentDuration)
      }).catch(err => {
        reject(err)
      })
    })
  }

  expectedLastRepayment () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.repaymentDeadline.call().then(expectedLastRepayment => {
        resolve(expectedLastRepayment)
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
}

export default new Loan()
