class CreateEliminations < ActiveRecord::Migration[7.0]
  def change
    create_table :eliminations, id: :string do |t|
      t.string :name
      t.references :tournament, type: :string, null: false, foreign_key: true

      t.timestamps
    end
  end
end
