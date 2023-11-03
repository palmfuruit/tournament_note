class TeamsController < ApplicationController
  def index
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @teams = @tournament.teams&.order(:entryNo)
    @teams_names = @teams.pluck(:name).join("\n")
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
      @teams = @tournament.teams&.order(:entryNo)
      @teams_names = @teams.pluck(:name).join("\n")
      # redirect_to tournament_teams_path(@tournament)
    else
      render 'form_update', status: :unprocessable_entity
    end
  end

  def bulk_update
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @teams = @tournament.teams&.order(:entryNo)
    @teams_names = params[:teams_names].split("\n")

    ActiveRecord::Base.transaction do
      @teams.delete_all
      @teams_names.each.with_index(1) do |team_name, i|
        next if team_name.blank? # 空行は無視
        @team = @tournament.teams.new(name: team_name)
        # 更新成功確認
        if !(@team.save)
          @error_team = @team
          render 'bulk_update', status: :unprocessable_entity and return
          raise ActiveRecord::Rollback
        end
      end
      @tournament.set_entryNo
    end

    # logger.debug("=============================")
    # logger.debug(@teams_names.to_yaml)
    # logger.debug("=============================")

    redirect_to tournament_teams_path(@tournament)
  end

  def destroy
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @team = Team.find_by(id: params[:id])

    @team.destroy
    @tournament.set_entryNo

    redirect_to tournament_teams_path(@tournament)
  end

  def shuffle
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

  private

  def team_params
    params.require(:team).permit(:tournament_id, :name, :color)
  end
end
