class AddOrderToTodos < ActiveRecord::Migration[7.1]
  def change
    add_column :todos, :order, :integer
  end
end
