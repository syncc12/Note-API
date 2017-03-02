class Note < ApplicationRecord
  has_many :tags
  validates :content, presence: true
end
