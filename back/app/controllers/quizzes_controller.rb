class QuizzesController < ApplicationController
  def show
    quiz = Quiz.find_by_id(params[:id])
    render json: quiz_json(quiz)
  end

  def create
    quiz = Quiz.new(quiz_params)
    result = quiz.save
    render json: quiz_json(quiz), status: result ? 200 : 422
  end

  def update
    quiz = Quiz.find_by_id(params[:id])
    result = quiz.update_attributes(quiz_params)
    render json: quiz_json(quiz), status: result ? 200 : 422
  end

  def index
    quizzes = Quiz.all
    render json: quizzes.collect do |q|
      {
        id: q.id,
        name: q.name
      }
    end
  end

  def destroy
    quiz = Quiz.find_by_id(params[:id])
    quiz.destroy

    render json: { result: :ok }
  end

  private

  def quiz_json(quiz)
    {
      name: quiz.name,
      id: quiz.id,
      errors: quiz.errors,
      questions: quiz.questions.collect do |q|
        {
          id: q.id,
          name: q.name,
          content: q.content,
          _destroy: q._destroy ? 1 : 0,
          errors: q.errors,
          options: q.options.collect do |o|
            {
              id: o.id,
              _destroy: o._destroy ? 1 : 0,
              content: o.content,
              errors: o.errors
            }
          end
        }
      end
    }
  end

  def quiz_params
    params
      .require(:quiz)
      .permit(
        [
          :name,
          questions_attributes: [
            :_destroy,
            :id,
            :name,
            :content,
            options_attributes: %I[
              id
              content
              _destroy
            ]
          ]
        ]
      )
  end
end
