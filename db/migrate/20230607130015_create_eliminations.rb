class CreateEliminations < ActiveRecord::Migration[7.0]
  def change
    create_table :eliminations do |t|
      t.string :name
      t.references :tournament, null: false, foreign_key: true

      t.timestamps
    end
  end
end
