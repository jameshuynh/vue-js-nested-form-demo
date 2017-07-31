class Quiz < ApplicationRecord
  validates :name, presence: true
  has_many :questions, dependent: :destroy

  accepts_nested_attributes_for :questions, allow_destroy: true

  validate :at_least_one_question

  private

  def at_least_one_question
    return unless questions.select { |x| x._destroy == false }.empty?
    errors.add(:questions, 'Quiz must have at least 1 question')
  end
end
