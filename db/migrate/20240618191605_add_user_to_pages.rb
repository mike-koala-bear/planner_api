class AddUserToPages < ActiveRecord::Migration[7.1]
  def change
    add_reference :pages, :user, foreign_key: true
  end
end
