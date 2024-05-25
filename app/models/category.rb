class Category < ApplicationRecord
  has_many :tasks
  belongs_to :user
  validates :name, presence: true, uniqueness: { scope: :user_id }
end
