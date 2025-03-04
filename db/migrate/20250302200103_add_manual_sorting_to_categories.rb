class AddManualSortingToCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :categories, :manual_sorting, :boolean
  end
end
