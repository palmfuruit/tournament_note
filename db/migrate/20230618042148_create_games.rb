class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.references :elimination, null: false, foreign_key: true
      t.integer :round
      t.integer :gameNo
      t.integer :a_team_id
      t.integer :b_team_id
      t.integer :win_team_id
      t.integer :lose_team_id
      t.string :a_result, limit: 4
      t.string :b_result, limit: 4
      t.string :a_score, limit: 16
      t.string :b_score, limit: 16
      t.timestamps
    end
  end
end
