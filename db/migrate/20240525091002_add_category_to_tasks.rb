class AddCategoryToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :category_id, :integer
  end
end
