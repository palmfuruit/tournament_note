class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games, id: :string do |t|
      t.references :tournament, type: :string, null: false, foreign_key: true
      t.integer :round
      t.integer :gameNo
      t.string :a_team_id
      t.string :b_team_id
      t.string :win_team_id
      t.string :lose_team_id
      t.string :a_result, limit: 4
      t.string :b_result, limit: 4
      t.string :a_score, limit: 16
      t.string :b_score, limit: 16
      t.timestamps
    end
  end
end
