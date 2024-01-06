class AddDescriptionToElimination < ActiveRecord::Migration[7.0]
  def change
    add_column :eliminations, :description, :text
  end
end
