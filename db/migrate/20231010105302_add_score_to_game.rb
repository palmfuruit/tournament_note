class AddScoreToGame < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :a_score_num, :integer, default: 0
    add_column :games, :b_score_num, :integer, default: 0
    add_column :games, :a_score_str, :string
    add_column :games, :b_score_str, :string

    remove_column :games, :a_score, :string
    remove_column :games, :b_score, :string
  end
end
