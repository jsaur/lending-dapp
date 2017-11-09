import Vue from 'vue'
import Router from 'vue-router'
import Home from '@/components/Home'
import Lend from '@/components/Lend'
import Borrow from '@/components/Borrow'
import Loan from '@/components/Loan'
import Converter from '@/components/Converter'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home
    },
    {
      path: '/lend',
      name: 'lend',
      component: Lend
    },
    {
      path: '/borrow',
      name: 'borrow',
      component: Borrow
    },
    {
      path: '/loan/:address',
      name: 'loan',
      component: Loan
    },
    {
      path: '/converter',
      name: 'currency-convert',
      component: Converter
    }
  ]
})
