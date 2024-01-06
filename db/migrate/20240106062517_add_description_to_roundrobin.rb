class AddDescriptionToRoundrobin < ActiveRecord::Migration[7.0]
  def change
    add_column :roundrobins, :description, :text
  end
end
