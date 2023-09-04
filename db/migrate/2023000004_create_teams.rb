class CreateTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :teams, id: :string do |t|
      t.string :name
      t.string :color
      t.integer :entryNo
      t.references :tournament, type: :string, null: false, foreign_key: true

      t.timestamps
    end
  end
end
