<template>
  <section id='createloan'>
    <h1>Create loan</h1>
    <div class="form">
      <div class="entry">
        <label for="loanAmountInEthers">Loan amount in ethers: </label>
        <input name="loanAmountInEthers" v-model="form.loanAmountInEthers">
        <br>
        <label for="repaymentDurationInDays">Repayment duration in days: </label>
        <input name="repaymentDurationInDays" v-model="form.repaymentDurationInDays">
        <br>
        <button @click="createloan" name="createloan">Create loan</button>
      </div>
    </div>
  </section>
</template>

<script>
  import LoanFactory from '@/js/loanfactory'

  export default {
    name: 'createloan',
    data () {
      return {
        form: {
          name: undefined
        }
      }
    },
    beforeCreate: function () {
      LoanFactory.init()
    },
    methods: {
      createloan: function () {
        let self = this
        if (typeof this.form.loanAmountInEthers !== 'undefined' && this.form.loanAmountInEthers !== '') {
          LoanFactory.create(this.form.loanAmountInEthers, this.form.repaymentDurationInDays).then(tx => {
            console.log(tx)
            self.$router.push('/')
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
