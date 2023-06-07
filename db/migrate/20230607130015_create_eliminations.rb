class CreateEliminations < ActiveRecord::Migration[7.0]
  def change
    create_table :eliminations do |t|
      t.string :name
      # t.boolean :has_playoff,  default: true

      t.timestamps
    end
  end
end
