class CreateTournaments < ActiveRecord::Migration[7.0]
  def change
    create_table :tournaments do |t|
      t.integer :tournament_type

      t.timestamps
    end
  end
end
