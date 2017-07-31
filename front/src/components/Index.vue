<template>
  <div class="col-md-12">

    <div
       v-if='showSuccessfulSaveMessage'
      class="alert alert-success"
      role="alert">
      Quiz has been save successfully!
    </div>

    <div
       v-if='showSuccessfulRemovedMessage'
      class="alert alert-danger"
      role="alert">
      Quiz has been removed successfully!
    </div>

    <div style='text-align:right;'>
      <button
         v-on:click="newQuiz"
        class="btn btn-success">+ New Quiz</button>
    </div>
    <br/>
    <table class='table'>
      <thead>
        <tr>
          <th>#</th>
          <th>Name</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(quiz, index) in quizzes">
          <td style='width: 30px'>{{ index + 1 }}</td>
          <td style='width: calc(100% - 210px)'>{{ quiz.name }}</td>
          <td style='width: 180px'>
            <button
              v-on:click="editQuiz(quiz.id)"
              class="btn btn-primary">Edit</button>
            &nbsp;

            <button
              v-on:click="removeQuiz(quiz.id, quiz.name)"
              class="btn btn-danger">Remove</button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import axios from 'axios'
let baseURL = 'http://localhost:3000'

export default {
  data () {
    return {
      quizzes: [],
      showSuccessfulSaveMessage: false,
      showSuccessfulRemovedMessage: false
    }
  },
  mounted () {
    if (this.$route.query.success === 'true') {
      this.showSuccessfulSaveMessage = true
      window.setTimeout(() => {
        this.showSuccessfulSaveMessage = false
      }, 2000)
    }

    axios
      .get(baseURL + '/quizzes.json')
      .then((response) => {
        this.quizzes = response.data
      })
  },
  methods: {
    newQuiz () {
      this.$router.push('/quizzes/new')
    },

    editQuiz (quizId) {
      this.$router.push('/quizzes/' + quizId)
    },

    removeQuiz (quizId, quizName) {
      let result = window.confirm(
        'Are you sure that you want to remove quiz "' + quizName + '" quiz?')
      if (result) {
        this.quizzes = this.quizzes.filter((el) => {
          return el.id !== quizId
        })

        this.showSuccessfulRemovedMessage = true
        window.setTimeout(() => {
          this.showSuccessfulRemovedMessage = false
        }, 2000)

        axios
          .delete(baseURL + '/quizzes/' + quizId + '.json')
          .then((response) => {
          })
      }
    }
  }
}
</script>
