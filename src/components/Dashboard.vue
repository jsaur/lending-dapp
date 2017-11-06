<template>
  <div class="dashboard">
    <h1>Welcome to the lending dApp</h1>
    <div>
      Current loan count: {{ loanCount }}
    </div>
    <div>
      Create a loan <router-link to="/createloan">here</router-link>.
    </div>
    <div v-if="loans">
    </div>
  </div>
</template>

<script>
import LoanFactory from '@/js/loanfactory'
import Loan from '@/js/loan'

export default {
  name: 'dashboard',
  data () {
    return {
      loanCount: undefined
    }
  },
  computed: {
    // here's a way we can get all the loans, and some properties off them.
    // @todo figure out a nice way to display these
    loans: function () {
      let loans = []
      if (this.loanCount > 0) {
        for (let i = 0; i < this.loanCount; i++) {
          LoanFactory.loans(i).then((loanAddress) => {
            Loan.init(loanAddress).then(() => {
              Loan.loanAmount().then(loanAmount => {
                loans.push({
                  address: loanAddress,
                  amount: parseInt(loanAmount, 10)
                })
              })
            })
          })
        }
      }
      console.log(loans)
      return loans
    }
  },
  beforeCreate: function () {
    LoanFactory.init().then(() => {
      LoanFactory.loanCount().then((loanCount) => {
        this.loanCount = parseInt(loanCount, 10)
        console.log('loanCount: ' + this.loanCount)
      })
    }).catch(err => {
      console.log(err)
    })
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1, h2 {
  font-weight: normal;
  display: block;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  display: inline-block;
  margin: 0 10px;
}

a {
  color: #42b983;
}
</style>
