class Teams::ShufflesController < ApplicationController
  def create
    @tournament = Tournament.find_by(id: params[:tournament_id])
    team_shuffle = TeamsShuffle.new(@tournament)
    team_shuffle.shuffle

    redirect_to tournament_teams_path(@tournament)
  end
end
