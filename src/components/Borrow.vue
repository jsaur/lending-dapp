<template>
  <section id='borrow'>
    <div v-if="hasLoan">
      <p>Your have a loan! Check it out here:</p>
      <router-link :to="{ name: 'loan', params: { address: loanAddress }}">{{loanAddress}}</router-link>
    </div>
    <div v-else>
      <h1>Create loan</h1>
      <div class="form">
        <div class="entry">
          <label for="name">Your name: </label>
          <input name="name" v-model="form.name">
          <br>
          <label for="use">Loan use: </label>
          <input name="use" v-model="form.use">
          <br>
          <label for="loanAmountInEthers">Loan amount in ethers: </label>
          <input name="loanAmountInEthers" v-model="form.loanAmountInEthers">
          <br>
          <label for="repaymentDurationInDays">Repayment duration in days: </label>
          <input name="repaymentDurationInDays" v-model="form.repaymentDurationInDays">
          <br>
          <button @click="createloan" name="createloan">Create loan</button>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
  import LoanFactory from '@/js/loanfactory'

  export default {
    name: 'borrow',
    data () {
      return {
        loanAddress: undefined,
        form: {
          name: undefined
        }
      }
    },
    computed: {
      hasLoan: function () {
        return (typeof this.loanAddress !== 'undefined')
      }
    },
    beforeCreate: function () {
      LoanFactory.init().then(() => {
        LoanFactory.getLoanForBorrower().then(loanAddress => {
          if (loanAddress && loanAddress !== '0x0000000000000000000000000000000000000000') {
            this.loanAddress = loanAddress
          }
        })
      })
    },
    methods: {
      createloan: function () {
        if (typeof this.form.loanAmountInEthers !== 'undefined' && this.form.loanAmountInEthers !== '') {
          // @todo more error checking
          LoanFactory.create(
            this.form.loanAmountInEthers,
            this.form.repaymentDurationInDays,
            this.form.name,
            this.form.use
          ).then(tx => {
            console.log(tx)
            // This seems a bit round about, there may be a better way
            this.loanAddress = tx.logs[0].args.loanAddress
          }).catch(err => {
            console.log(err)
          })
        }
      }
    }
  }
</script>

<style lang="scss" scoped>

  #signup {
    text-align: center;

    .form {
      display: flex;
      flex-direction: column;
      margin: auto;

      .entry {
        display: flex;
        flex-direction: row-reverse;
        justify-content: center;

        label {
          margin-right: 20px
        }

        button {
          margin-left: 20px
        }

      }

    }

  }

</style>
