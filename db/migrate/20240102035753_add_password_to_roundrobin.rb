class AddPasswordToRoundrobin < ActiveRecord::Migration[7.0]
  def change
    add_column :roundrobins, :password, :string
  end
end
