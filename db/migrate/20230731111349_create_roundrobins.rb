class CreateRoundrobins < ActiveRecord::Migration[7.0]
  def change
    create_table :roundrobins do |t|
      t.string :name
      t.references :tournament, null: false, foreign_key: true
      t.integer :num_of_round,  default: 1
      t.integer :rank1,  default: 1

      t.timestamps
    end
  end
end
