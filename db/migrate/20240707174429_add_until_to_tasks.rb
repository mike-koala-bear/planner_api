class AddUntilToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :until, :datetime
  end
end
