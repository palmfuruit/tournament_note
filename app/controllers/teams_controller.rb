class TeamsController < ApplicationController
  def index
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @teams = @tournament.teams&.order(:entryNo)
  end

  def new
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @team = @tournament.teams.new
  end

  def create
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @team = @tournament.teams.new(team_params)
    # 更新成功確認
    if @team.save
      @tournament.set_entryNo
      redirect_to tournament_teams_path(@tournament)
    else
      render 'form_update', status: :unprocessable_entity
    end
  end

  def edit
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @team = Team.find_by(id: params[:id])
  end

  def update
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @team = Team.find_by(id: params[:id])

    if @team.update(team_params)
      # redirect_to elimination_teams_path(@elimination)
    else
      render 'form_update', status: :unprocessable_entity
    end
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
end
