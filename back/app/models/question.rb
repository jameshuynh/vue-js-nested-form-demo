class Question < ApplicationRecord
  validates :name, presence: true
  validates :content, presence: true

  has_many :options, dependent: :destroy

  accepts_nested_attributes_for :options, allow_destroy: true

  validate :at_least_2_options

  private

  def at_least_2_options
    return unless options.select { |x| x._destroy == false }.length < 2
    errors.add(:options, 'Question must have at least 2 options')
  end
end
