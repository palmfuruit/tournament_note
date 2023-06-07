class TeamsController < ApplicationController
  def index
    @elimination = Elimination.find_by(id: params[:elimination_id])
    @teams = @elimination.teams&.order(:entryNo)
  end

  def new
    @elimination = Elimination.find_by(id: params[:elimination_id])
    @team = @elimination.teams.new
  end

  def create
    @elimination = Elimination.find_by(id: params[:elimination_id])
    @team = @elimination.teams.new(team_params)
    # 更新成功確認
    if @team.save
      @elimination.set_entryNo
      redirect_to elimination_teams_path(@elimination)
    else
      render 'form_update', status: :unprocessable_entity
    end
  end

  def edit
    @elimination = Elimination.find_by(id: params[:elimination_id])
    @team = Team.find_by(id: params[:id])

  end

  def update
    @elimination = Elimination.find_by(id: params[:elimination_id])
    @team = Team.find_by(id: params[:id])

    if @team.update(team_params)
      # redirect_to elimination_teams_path(@elimination)
    else
      render 'form_update', status: :unprocessable_entity
    end
  end

  def destroy
    @elimination = Elimination.find_by(id: params[:elimination_id])
    @team = Team.find_by(id: params[:id])

    @team.destroy
    @elimination.set_entryNo

    redirect_to elimination_teams_path(@elimination)
  end

  private

  def team_params
    params.require(:team).permit(:elimination_id, :name)
  end
end
