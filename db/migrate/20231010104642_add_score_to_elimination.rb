class AddScoreToElimination < ActiveRecord::Migration[7.0]
  def change
    add_column :eliminations, :has_score, :boolean, default: false
  end
end
