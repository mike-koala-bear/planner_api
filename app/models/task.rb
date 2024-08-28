class Task < ApplicationRecord
  belongs_to :user
  belongs_to :category
  validates :description, presence: true

  # Define priority levels
  enum priority: { low: 0, medium: 1, high: 2, urgent: 3 }

  # Validate presence and inclusion of priority
  validates :priority, presence: true, inclusion: { in: priorities.keys }
end
