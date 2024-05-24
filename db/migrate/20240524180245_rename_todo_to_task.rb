class RenameTodoToTask < ActiveRecord::Migration[7.1]
  def change
    rename_table :todos, :tasks
  end
end
