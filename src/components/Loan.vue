<template>
  <div class="loan">
    <div class="general">
      <p>Loan contract address: {{ address }}</p>
      <p>Name: {{ name }}</p>
      <p>Loan amount: {{ loanAmount }} ETH</p>
      <p>Amount raised: {{ amountRaised }} ETH</p>
      <p>Expected last repayent: {{ expectedLastRepayment }}</p>
    </div>
    <div class="borrower" v-if="isBorrower">
      <p>You are the borrower</p>
    </div>
    <div class="lender" v-else>
      <div class="lend-button">
        <label for="lendAmount">Amount to lend (ETH): </label>
        <input name="lendAmount" v-model="form.lendAmount">
        <button @click="lendToLoan" name="lendToLoan">Lend to loan</button>
      </div>
      <div v-if="hasLent">
        <br>
        <p>Thanks for lending!</p>
        <p>Amount lent: {{ lenderAccount.amountLent }} ETH</p>
        <p>Amount repaid: {{ lenderAccount.amountRepaid }} ETH</p>
        <p>Amount withdrawn: {{ lenderAccount.amountWithdrawn }} ETH</p>
      </div>
    </div>
  </div>
</template>

<script>
  import Loan from '@/js/loan'

  export default {
    name: 'loan',
    data () {
      return {
        address: this.address,
        borrowerAddress: undefined,
        name: undefined,
        loanAmount: undefined,
        amountRaised: 0,
        repaymentDuration: undefined,
        expectedLastRepayment: undefined,
        hasLent: undefined,
        lenderAccount: undefined,
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
        Loan.borrowerAddress().then(borrowerAddress => {
          this.borrowerAddress = borrowerAddress
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
      })
    },
    methods: {
      lendToLoan: function () {
        let self = this
        if (this.form.lendAmount > 0) {
          Loan.lend(this.form.lendAmount).then(tx => {
            console.log(tx)
            self.hasLent = true
            this.refreshLendData()
          }).catch(err => {
            console.log(err)
          })
        }
      },
      refreshLendData: function () {
        // @todo for some reason this still pulls stale values from the contract, need to figure how to force updated values
        console.log('refresh')
        Loan.amountRaised().then(amountRaised => {
          this.amountRaised = parseFloat(amountRaised, 10)
          console.log(this.amountRaised)
        })
        Loan.lenderAccounts().then(lenderAccount => {
          if (lenderAccount.amountLent > 0) {
            this.hasLent = true
            this.lenderAccount = lenderAccount
            console.log(this.lenderAccount.amountLent)
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
