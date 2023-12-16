class AddPasswordToElimination < ActiveRecord::Migration[7.0]
  def change
    add_column :eliminations, :password, :string
  end
end
