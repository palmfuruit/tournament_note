class Teams::BulkUpdatesController < ApplicationController
  def create
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @teams = @tournament.teams&.order(:entryNo)
    @teams_names = params[:teams_names].split("\n").reject { |name| name.blank? }

    ActiveRecord::Base.transaction do
      @teams.delete_all
      @teams_names.each.with_index(1) do |team_name, i|
        @team = @tournament.teams.new(name: team_name, entryNo: i)
        @team.save!
      end
    end

    redirect_to tournament_teams_path(@tournament) and return

  rescue ActiveRecord::RecordInvalid
    render :create, status: :unprocessable_entity

  end
end
