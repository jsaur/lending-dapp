<template>
  <div class="homepage">
    <h1>Welcome to the p2p microfinance dApp</h1>
    <h2>Blockchain lending powered by Ethereum</h2>
    <div id="lend-button">
      <router-link tag="button" to='/dashboard'>LEND</router-link>
    </div>
    <div id="borrow-button">
      <router-link tag="button" to="/createloan">BORROW</router-link>
    </div>

  </div>
</template>


<script>

export default {
  name: 'homepage',
  data () {
    return {
    }
  },
  computed: {
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
