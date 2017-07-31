<template>
  <div class="nested-form col-md-6 col-md-offset-3">
    <h3>{{ header }}</h3>
    <hr/>
    <div v-if='loading' class='loader-container'>
      <div class='loader'></div>
      Loading
    </div>
    <form id='nested_form' v-else>

      <div class='form-group'>
        <label>Quiz Name</label>
        <input
          v-model='quiz.name'
          name='quiz[name]'
          type='text'
          class='form-control' />
        <span
            class='error'
            v-if='quiz.errors.name'>
            {{ quiz.errors.name.join(', ') }}
          </span>
      </div>

      <div
        class='alert alert-danger group-error'
        v-if="quiz.errors.questions">
        {{ quiz.errors.questions.join(', ') }}
      </div>

      <div class='question-nested-fields'>
        <div
          v-bind:class="'field-for-question ' +
          (question._destroy == 1 ? 'hidden' : '')"
          v-for="(question, qindex) in quiz.questions">
          <hr />
          <h3 class='clearfix'>
            Question {{ question.position }}
            <span
              v-on:click="removeQuestion(qindex)"
              class='btn btn-sm btn-danger'
              style='font-size: 8px; float: right;'>
              X
            </span>
          </h3>
          <input
            v-bind:name=
              '"quiz[questions_attributes][" + qindex + "][_destroy]"'
            type='hidden'
            v-model='question._destroy' />
          <input
            v-bind:name=
              '"quiz[questions_attributes][" + qindex + "][id]"'
            type='hidden'
            v-model='question.id' />
          <div class='form-group'>
            <label>Question Name</label>
            <input
              v-model='question.name'
              v-bind:name=
                '"quiz[questions_attributes][" + qindex + "][name]"'
              type='text' class='form-control' />
            <span
              class='error'
              v-if='question.errors.name'>
              {{ question.errors.name.join(', ') }}
            </span>
          </div>
          <div class='form-group'>
            <label>Question Content</label>
            <textarea
              v-model='question.content'
              v-bind:name=
                '"quiz[questions_attributes][" + qindex + "][content]"'
              class='form-control' />
            <span
              class='error'
              v-if='question.errors.content'>
              {{ question.errors.content.join(', ') }}
            </span>
          </div>

          <div
            class='group-error alert alert-danger'
            v-if="question.errors.options">
            {{ question.errors.options.join(', ') }}
          </div>

          <div class='option-nested-fields'>
            <div
              v-bind:class="'field-for-options ' +
                (option._destroy == 1 ? 'hidden' : '')"
              v-for="(option, oindex) in question.options">
              <div class='form-group'>
                <label style='width: 100%;' class='clearfix'>
                  Option {{ option.position }}
                  <span
                    v-on:click="removeOption(qindex, oindex)"
                    class='btn btn-sm btn-danger'
                    style='font-size: 8px; float: right;'>
                    X
                  </span>
                </label>
                <input
                  v-bind:name=
                    '"quiz[questions_attributes][" + qindex + "]\
[options_attributes][" + oindex + "][_destroy]"'
                  type='hidden'
                  v-model='option._destroy' />
                <input
                  v-bind:name=
                    '"quiz[questions_attributes][" + qindex + "]\
[options_attributes][" + oindex + "][id]"'
                  type='hidden'
                  v-model='option.id' />
                <input
                  type='text'
                  v-bind:name=
                    '"quiz[questions_attributes][" + qindex + "]\
[options_attributes][" + oindex + "][content]"'
                  class='form-control'
                  v-model='option.content' />
                <span
                  class='error'
                  v-if='option.errors.content'>
                  {{ option.errors.content.join(', ') }}
                </span>
              </div>
            </div>
            <button
              v-on:click="addMoreOption(qindex)"
              class="btn btn-warning">
              + Add More Option
            </button>
          </div>
          <br/>
        </div>
        <button
          v-on:click="addMoreQuestion"
          class="btn btn-success">
          + Add More Question
        </button>
      </div>
      <br/>
      <button
        v-on:click="submit"
        v-bind:disabled='submitting'
        class="btn btn-primary">
        {{ submitting ? 'Saving...' : 'Save' }}
      </button>
      <button
        class="btn btn-default"
        v-on:click="cancel">
        Cancel
      </button>
    </form>
    <br />
    <br />
  </div>
</template>

<script>
import axios from 'axios'

let baseURL = 'http://localhost:3000'

let emptyOption = {
  content: '',
  _destroy: 0,
  position: 1,
  errors: {}
}

let emptyQuestion = {
  name: '',
  content: '',
  errors: {},
  position: 1,
  _destroy: 0,
  options: [
    Object.assign({}, emptyOption),
    Object.assign(emptyOption, { position: 2 })
  ]
}

let cloneQuestion = JSON.parse(JSON.stringify(emptyQuestion))
let mainData = {
  submitting: false,
  loading: true,
  header: '',
  quiz: {
    name: '',
    errors: {},
    questions: [
      cloneQuestion
    ]
  }
}

export default {
  data () {
    return mainData
  },
  mounted () {
    if (this.$route.params.id) {
      axios
        .get(baseURL + '/quizzes/' +
          this.$route.params.id + '.json')
        .then((response) => {
          this.loading = false
          this.handleResponse(response)
          this.header = response.data.name
        })
    } else {
      this.loading = false
      this.header = 'New Quiz'
    }
  },
  methods: {
    addMoreOption (qIndex) {
      event.preventDefault()
      let cloneOption = Object.assign({}, emptyOption)
      cloneOption.position =
        this.quiz.questions[qIndex].options.filter((option) => {
          return option._destroy === 0
        }).length + 1
      this.quiz.questions[qIndex].options.push(cloneOption)
    },

    addMoreQuestion (event) {
      event.preventDefault()
      let cloneQuestion = JSON.parse(JSON.stringify(emptyQuestion))
      cloneQuestion.position =
        this.quiz.questions.filter((question) => {
          return question._destroy === 0
        }).length + 1
      this.quiz.questions.push(cloneQuestion)
    },

    removeQuestion (qIndex) {
      this.quiz.questions[qIndex]._destroy = 1
      let index = 1
      this.quiz.questions.forEach((question) => {
        if (question._destroy === 0) {
          question.position = index
          index++
        }
      })

      // James: without this force update, it will not render after first
      // load on existing entry
      this.$forceUpdate()
    },

    removeOption (qIndex, oIndex) {
      this.quiz.questions[qIndex].options[oIndex]._destroy = 1
      let index = 1
      this.quiz.questions[qIndex].options.forEach((option) => {
        if (option._destroy === 0) {
          option.position = index
          index++
        }
      })

      // James: without this force update, it will not render after first
      // load on existing entry
      this.$forceUpdate()
    },

    cancel () {
      this.$router.push('/quizzes/')
    },

    submit (event) {
      event.preventDefault()
      this.submitting = true
      let data = new FormData(document.getElementById('nested_form'))
      let url, action
      if (this.$route.params.id) {
        url = baseURL + '/quizzes/' + this.$route.params.id + '.json'
        action = 'patch'
      } else {
        url = baseURL + '/quizzes.json'
        action = 'post'
      }

      axios[action](url, data)
        .then((response) => {
          this.submitting = false
          this.$router.push('/quizzes?success=true')
        })
        .catch((error) => {
          this.handleResponse(error.response)
        })
    },

    handleResponse (response) {
      this.quiz = response.data
      this.quiz.questions = response.data.questions
      this.submitting = false

      let qindex = 1
      this.quiz.questions.forEach((question) => {
        if (typeof (question._destroy) === 'undefined') {
          question._destroy = 0
        }

        if (question._destroy === 0) {
          question.position = qindex
          qindex++
        }

        let oindex = 1
        question.options.forEach((option) => {
          if (typeof (option._destroy) === 'undefined') {
            option._destroy = 0
          }

          if (option._destroy === 0) {
            option.position = oindex
            oindex++
          }
        })
      })
    }
  }
}
</script>


<style scoped>
.error {
  display: block;
  margin-top: 0px;
  background: #800;
  color: #fff;
  padding: 5px 10px;
  border-radius: 3px
}

.loader {
  border: 8px solid #ccc; /* Light grey */
  border-top: 8px solid #333; /* Blue */
  border-radius: 50%;
  width: 40px;
  height: 40px;
  margin: 0 auto;
  animation: spin 2s linear infinite;
  margin-bottom: 10px;
}

.loader-container {
  text-align: center;
  color: #999;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>
