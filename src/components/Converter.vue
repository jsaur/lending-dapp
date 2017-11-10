<template>
  <div class="currency-convert">
    <h1>
    {{ dollarAmt }} dollar is
    {{ ether }}  ether

  </h1>

  </div>
</template>


<script>
import axios from 'axios'

export default {
  name: 'currency-convert',
  // props: {dollarAmt: 1},
  data () {
    return {
      dollarAmt: 1,
      ether: ''
    }
  },

  created () {
    // triggerAjax: function () {
    this.getDollarEthConversion()

    // this.
    // }
  },
  methods: {
  // Fetches posts when the component is created.
    getDollarEthConversion: function () {
      console.log('more messages')
      var vm = this
      axios.get(`https://min-api.cryptocompare.com/data/price?fsym=USD&tsyms=ETH`)
      .then((response) => {
        // JSON responses are automatically parsed.
        // this.posts = response.data
        console.log(response)

        vm.ether = response.data.ETH
      })
      .catch(e => {
        // this.errors.push(e)
        vm.ether = "i'm having hard time, give me a moment"
      })
    }
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
