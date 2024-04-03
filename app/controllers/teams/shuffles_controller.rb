class Teams::ShufflesController < ApplicationController
  def create
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @teams = @tournament.teams&.order(:entryNo)

    entry_numbers = (1..@teams.size).to_a
    @teams.each do |team|
      number = entry_numbers.sample
      team.update(entryNo: number)
      entry_numbers.delete(number)
    end
    @teams = @tournament.teams&.order(:entryNo)

    redirect_to tournament_teams_path(@tournament)
  end
end
