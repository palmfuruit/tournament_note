class AddScoreToRoundrobin < ActiveRecord::Migration[7.0]
  def change
    add_column :roundrobins, :has_score, :boolean, default: false
    add_column :roundrobins, :rank2, :integer, default: 0
    add_column :roundrobins, :rank3, :integer, default: 0
    add_column :roundrobins, :rank4, :integer, default: 0
  end
end
