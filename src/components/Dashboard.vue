<template>
  <div class="dashboard">
    <h1>{{ msg }}</h1>
    <div v-if="loanExists">
      Welcome {{ name }}.
    </div>
    <div v-else>Create a loan <router-link to="/createloan">here</router-link>.</div>
  </div>
</template>

<script>
import LoanFactory from '@/js/loanfactory'

export default {
  name: 'dashboard',
  data () {
    return {
      msg: 'Welcome to the lending dApp',
      name: undefined
    }
  },
  computed: {
    loanExists: function () {
      return (typeof this.name !== 'undefined')
    }
  },
  beforeCreate: function () {
    LoanFactory.init().then(() => {
      LoanFactory.exists(window.web3.eth.accounts[0]).then((exists) => {
        if (exists) {
         // Users.authenticate().then(pseudo => {
         //   this.pseudo = pseudo
         // })
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
  display: inline-block;
  margin: 0 10px;
}

a {
  color: #42b983;
}
</style>
