class TeamsController < ApplicationController
  before_action :authenticate_owner

  def index
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @teams = @tournament.teams&.order(:entryNo)
    @teams_names = @teams.pluck(:name).join("\n")
  end

  def new
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @team = @tournament.teams.new.decorate
  end

  def create
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @team = @tournament.teams.new(team_params)
    # 更新成功確認
    if @team.save
      @team = @team.decorate
      @tournament.set_entryNo
      redirect_to tournament_teams_path(@tournament)
    else
      @team = @team.decorate
      render 'form_update', status: :unprocessable_entity
    end
  end

  def edit
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @team = Team.find_by(id: params[:id]).decorate
  end

  def update
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @team = Team.find_by(id: params[:id])

    if @team.update(team_params)
      @team = @team.decorate
      @teams = @tournament.teams&.order(:entryNo)
      @teams_names = @teams.pluck(:name).join("\n")
      # redirect_to tournament_teams_path(@tournament)
    else
      @team = @team.decorate
      render 'form_update', status: :unprocessable_entity
    end
  end

  def bulk_update
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

    # logger.debug("=============================")
    # logger.debug(@teams_names.to_yaml)
    # logger.debug("=============================")

    redirect_to tournament_teams_path(@tournament) and return

  rescue ActiveRecord::RecordInvalid
    render 'bulk_update', status: :unprocessable_entity and return

  end

  def destroy
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @team = Team.find_by(id: params[:id])

    @team.destroy
    @tournament.set_entryNo

    redirect_to tournament_teams_path(@tournament)
  end



  private

  def team_params
    params.require(:team).permit(:tournament_id, :name, :color)
  end

  def authenticate_owner
    tournament = Tournament.find_by(id: params[:tournament_id])
    unless view_context.tournament_owner?(tournament)
      if tournament.elimination?
        redirect_to elimination_path(tournament.elimination)
      else
        redirect_to roundrobin_path(tournament.roundrobin)
      end
    end
  end

end
