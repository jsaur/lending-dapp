<template>
  <div class="loan">
    <div class="general">
      <p>Loan contract address: {{ address }}</p>
      <p>Name: {{ name }}</p>
      <p>Loan amount: {{ loanAmount }} ETH</p>
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
  import LoanFactory from '@/js/loanfactory'

  export default {
    name: 'loan',
    data () {
      return {
        address: this.address,
        borrowerAddress: undefined,
        name: undefined,
        currentState: undefined,
        loanAmount: undefined,
        amountRaised: 0,
        amountRepaid: 0,
        repaymentDuration: undefined,
        expectedLastRepayment: undefined,
        hasLent: undefined,
        lenderAccount: undefined,
        amountCanWithdraw: undefined,
        form: {
          lendAmount: undefined
        }
      }
    },
    computed: {
      isBorrower: function () {
        return (this.borrowerAddress === this.address)
      }
    },
    beforeCreate () {
      this.address = this.$route.params.address
      Loan.init(this.address).then(() => {
        // @todo this is giving me an opt code error, not sure why
        // Loan.borrowerAddress().then(borrowerAddress => {
        //  this.borrowerAddress = borrowerAddress
        // })
        // Until I can figure out the above issue, just going to use the LoanFactory (lame)
        LoanFactory.init().then(() => {
          LoanFactory.getLoanForBorrower().then(borrowerAddress => {
            if (borrowerAddress && borrowerAddress !== '0x0000000000000000000000000000000000000000') {
              this.borrowerAddress = borrowerAddress
            }
          })
        })

        Loan.name().then(name => {
          this.name = name
        })
        Loan.loanAmount().then(loanAmount => {
          this.loanAmount = parseFloat(loanAmount, 10)
        })
        Loan.expectedLastRepayment().then(expectedLastRepayment => {
          this.expectedLastRepayment = new Date(expectedLastRepayment * 1000)
        })
        this.refreshLendData()
        this.refreshRepayData()
      })
    },
    methods: {
      // lender functions
      lendToLoan: function () {
        let self = this
        if (this.form.lendAmount > 0) {
          Loan.lend(this.form.lendAmount).then(tx => {
            console.log(tx)
            self.hasLent = true
            this.refreshLendData()
            this.refreshRepayData()
          }).catch(err => {
            console.log(err)
          })
        }
      },
      refreshLendData: function () {
        // @todo for some reason this still pulls stale values from the contract, need to figure how to force updated values
        console.log('refreshLendData')
        Loan.amountRaised().then(amountRaised => {
          this.amountRaised = parseFloat(amountRaised, 10)
          console.log(this.amountRaised)
        })
        Loan.lenderAccounts().then(lenderAccount => {
          if (lenderAccount && lenderAccount.amountLent > 0) {
            this.hasLent = true
            this.lenderAccount = lenderAccount
            Loan.amountLenderCanWithdraw().then(amountCanWithdraw => {
              this.amountCanWithdraw = amountCanWithdraw
            })
          }
        })
      },
      lenderWithdraw: function () {
        Loan.lenderWithdraw().then(tx => {
          console.log(tx)
          this.refreshLendData()
        }).catch(err => {
          console.log(err)
        })
      },

      // borrower functions
      borrowerWithdraw: function () {
        Loan.borrowerWithdraw().then(tx => {
          console.log(tx)
          this.refreshRepayData()
        }).catch(err => {
          console.log(err)
        })
      },
      repayToLoan: function () {
        if (this.form.repayAmount > 0) {
          Loan.repay(this.form.repayAmount).then(tx => {
            console.log(tx)
            this.refreshRepayData()
          }).catch(err => {
            console.log(err)
          })
        }
      },
      refreshRepayData: function () {
        console.log('refreshRepayData')
        Loan.currentState().then(currentState => {
          this.currentState = currentState
        })
        Loan.amountRepaid().then(amountRepaid => {
          this.amountRepaid = parseFloat(amountRepaid, 10)
          console.log(this.amountRepaid)
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
