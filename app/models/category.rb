class Category < ApplicationRecord
  has_many :tasks, ->(category) {
    order(category.manual_sorting ? "\"order\" ASC" : "created_at ASC")
  }, dependent: :destroy
  belongs_to :user
  validates :name, presence: true, uniqueness: { scope: :user_id }
end
