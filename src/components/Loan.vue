<template>
  <div class="loan">
    <div class="general">
      <p>Loan contract address: {{ address }}</p>
      <p>Name: {{ name }}</p>
      <p>Use: {{ use }}</p>
      <p>Loan amount: {{ loanAmount }} ETH</p>
      <p>Repayment duration: {{ repaymentDuration }} days</p>
      <p>Expected last repayent: {{ expectedLastRepayment }}</p>
      <p>Current State: {{ currentState }}</p>
      <p v-if="currentState === 'raising'">Amount raised: {{ amountRaised }} ETH</p>
      <p v-if="currentState === 'repaying'">Amount repaid: {{ amountRepaid }} ETH</p>
    </div>
    <div class="borrower" v-if="isBorrower">
      <p>This is your loan</p>

      <div v-if="currentState === 'funded'" class="borrower-withdraw-button">
        <button @click="borrowerWithdraw" name="borrowerWithdraw">Borrower withdraw</button>
      </div>

      <div v-if="currentState === 'repaying'" class="repay-button">
        <label for="repayAmount">Amount to repay (ETH): </label>
        <input name="repayAmount" v-model="form.repayAmount">
        <button @click="repayToLoan" name="repayToLoan">Repay to loan</button>
      </div>
    </div>
    <div class="lender" v-else>
      <div v-if="currentState === 'raising'" class="lend-button">
        <label for="lendAmount">Amount to lend (ETH): </label>
        <input name="lendAmount" v-model="form.lendAmount">
        <button @click="lendToLoan" name="lendToLoan">Lend to loan</button>
      </div>
      <div v-if="hasLent">
        <br>
        <p>Thanks for lending!</p>
        <p>Amount lent: {{ lenderAccount.amountLent }} ETH</p>
        <p>Amount repaid: {{ lenderAccount.amountRepaid }} ETH</p>
        <p>Amount can withdraw: {{ amountCanWithdraw }} ETH</p>
        <p>Amount withdrawn: {{ lenderAccount.amountWithdrawn }} ETH</p>
      </div>
      <div v-if="amountCanWithdraw > 0" class="lender-withdraw-button">
        <button @click="lenderWithdraw" name="lenderWithdraw">Lender withdraw</button>
      </div>
    </div>
  </div>
</template>

<script>
  // @todo break up into vue components: general, borrower and lender
  import Loan from '@/js/loan'

  export default {
    name: 'loan',
    data () {
      return {
        address: this.address,
        borrowerAddress: undefined,
        name: undefined,
        use: undefined,
        currentState: undefined,
        loanAmount: undefined,
        amountRaised: 0,
        amountRepaid: 0,
        repaymentDuration: undefined,
        expectedLastRepayment: undefined,
        hasLent: undefined,
        lenderAccount: {
          amountLent: 0,
          amountRepaid: 0,
          amountWithdrawn: 0
        },
        amountCanWithdraw: 0,
        form: {
          lendAmount: undefined,
          repayAmount: undefined
        }
      }
    },
    computed: {
      isBorrower: function () {
        return (this.borrowerAddress === window.web3.eth.accounts[0])
      }
    },
    beforeCreate () {
      this.address = this.$route.params.address
      Loan.init(this.address).then(() => {
        Loan.borrowerAddress().then(borrowerAddress => {
          this.borrowerAddress = borrowerAddress
        })
        Loan.ipfsInfo().then(ipfsInfo => {
          this.name = ipfsInfo.name
          this.use = ipfsInfo.use
        })
        Loan.loanAmount().then(loanAmount => {
          this.loanAmount = loanAmount
        })
        Loan.repaymentDuration().then(repaymentDuration => {
          this.repaymentDuration = repaymentDuration
        })
        Loan.expectedLastRepayment().then(expectedLastRepayment => {
          this.expectedLastRepayment = expectedLastRepayment
        })

        // Hack: contracts can take awhile to update their state, there's probably a better way to monitor this, but for now will just run a refresh job on a timer
        let self = this
        self.refreshData()
        window.setInterval(function () {
          self.refreshData()
        }, 500)
      })
    },
    methods: {
      // lender functions
      lendToLoan: function () {
        let self = this
        if (this.form.lendAmount > 0) {
          Loan.lend(this.form.lendAmount).then(tx => {
            console.log(tx)
            self.form.lendAmount = undefined
            self.refreshData()
          }).catch(err => {
            console.log(err)
          })
        }
      },
      lenderWithdraw: function () {
        let self = this
        Loan.lenderWithdraw().then(tx => {
          console.log(tx)
          self.refreshData()
        }).catch(err => {
          console.log(err)
        })
      },

      // borrower functions
      borrowerWithdraw: function () {
        let self = this
        Loan.borrowerWithdraw().then(tx => {
          console.log(tx)
          self.refreshData()
        }).catch(err => {
          console.log(err)
        })
      },
      repayToLoan: function () {
        let self = this
        if (this.form.repayAmount > 0) {
          Loan.repay(this.form.repayAmount).then(tx => {
            console.log(tx)
            self.form.repayAmount = undefined
            self.refreshData()
          }).catch(err => {
            console.log(err)
          })
        }
      },

      // refresh the vars that change often
      refreshData: function () {
        let self = this
        Loan.currentState().then(currentState => {
          self.currentState = currentState
        })
        Loan.amountRaised().then(amountRaised => {
          self.amountRaised = amountRaised
        })
        Loan.amountRepaid().then(amountRepaid => {
          self.amountRepaid = amountRepaid
        })
        Loan.lenderAccounts().then(lenderAccount => {
          if (lenderAccount && lenderAccount.amountLent > 0) {
            self.lenderAccount = lenderAccount
            self.hasLent = true
            Loan.amountLenderCanWithdraw().then(amountCanWithdraw => {
              self.amountCanWithdraw = amountCanWithdraw
            })
          }
        })
      }
    }

  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
a {
  color: #42b983;
}
</style>
