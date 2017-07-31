class Option < ApplicationRecord
  validates :content, presence: true
end
