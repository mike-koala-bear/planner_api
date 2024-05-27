class AddWidthAndHeightToCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :categories, :width, :integer
    add_column :categories, :height, :integer
  end
end
