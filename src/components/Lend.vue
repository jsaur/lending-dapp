<template>
  <div class="lend">
    <div>
      Current loan count: {{ loanCount }}
    </div>
    <div v-if="loans">
      <ul id="loan-list">
        <li v-for="loan in loans">
          <a v-bind:href="loan.url">{{loan.name}}</a>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import LoanFactory from '@/js/loanfactory'
import Loan from '@/js/loan'

export default {
  name: 'lend',
  data () {
    return {
      loanCount: undefined,
      loans: undefined
    }
  },
  beforeCreate: function () {
    LoanFactory.init().then(() => {
      LoanFactory.loanCount().then((loanCount) => {
        this.loanCount = parseInt(loanCount, 10)
        console.log('loanCount: ' + this.loanCount)

        // @todo there's probably a better way to iterate over each loan and fetch contract properties
        this.loans = []
        if (this.loanCount > 0) {
          for (let i = 0; i < this.loanCount; i++) {
            LoanFactory.loans(i).then((loanAddress) => {
              // @todo make this instantiate a new Loan
              // right now this can only fetch one property, multiple properties results in fetching them from the wrong contract
              let loanContract = Loan
              loanContract.init(loanAddress).then(() => {
                loanContract.name().then(name => {
                  let loan = {
                    address: loanAddress,
                    url: '/lend/' + loanAddress,
                    name: name
                  }
                  console.log(loan)
                  this.loans.push(loan)
                })
              })
            })
          }
        }
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
  margin: 0 10px;
}

a {
  color: #42b983;
}
</style>
