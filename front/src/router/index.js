import Vue from 'vue'
import Router from 'vue-router'
import NestedForm from '@/components/NestedForm'
import Index from '@/components/Index'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'Index',
      component: Index
    },
    {
      path: '/quizzes',
      name: 'Quizzes',
      component: Index
    },
    {
      path: '/quizzes/new',
      name: 'Quizzes',
      component: NestedForm
    },
    {
      path: '/quizzes/:id',
      name: 'NestedForm',
      component: NestedForm
    }
  ]
})
