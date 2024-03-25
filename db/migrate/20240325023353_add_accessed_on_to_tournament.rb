class AddAccessedOnToTournament < ActiveRecord::Migration[7.0]
  def change
    add_column :tournaments, :accessed_on, :date
  end
end
