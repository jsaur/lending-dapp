<template>
  <section id='createloan'>
    <h1>Create loan</h1>
    <div class="form">
      <div class="entry">
        <button @click="createloan" name="createloan">Create loan</button>
        <input name="name" v-model="form.name">
        <label for="name">Name</label>
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
        if (typeof this.form.name !== 'undefined' && this.form.name !== '') {
          LoanFactory.create(this.form.name).then(tx => {
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
