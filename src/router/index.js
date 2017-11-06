import Vue from 'vue'
import Router from 'vue-router'
import Lend from '@/components/Lend'
import Borrow from '@/components/borrow'
import Home from '@/components/Home'

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
    }
  ]
})
