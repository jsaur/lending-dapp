<template>
  <div class="dashboard">
    <h1>Welcome to the lending dApp</h1>
    <div>
      Current loan count: {{ loanCount }}
    </div>
    <div>
      Create a loan <router-link to="/createloan">here</router-link>.
    </div>
  </div>
</template>

<script>
import LoanFactory from '@/js/loanfactory'

export default {
  name: 'dashboard',
  data () {
    return {
      loanCount: undefined
    }
  },
  computed: {
  },
  beforeCreate: function () {
    LoanFactory.init().then(() => {
      LoanFactory.loanCount().then((loanCount) => {
        this.loanCount = parseInt(loanCount, 10)
        console.log(loanCount)
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
