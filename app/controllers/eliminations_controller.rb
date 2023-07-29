class EliminationsController < ApplicationController
  def index
    @eliminations = Elimination.all.order(created_at: :desc)
  end

  def show
    @elimination = Elimination.find_by(id: params[:id])
    unless @elimination
      flash[:warning] = "トーナメントが見つかりません。"
      redirect_to root_path and return
    end

    @teams = @elimination.teams.order(:entryNo).map(&:attributes)
    @games = @elimination.games.map(&:attributes)

    @round_offset = 0
  end

  def new
    @elimination = Elimination.new()
  end

  def create
    ActiveRecord::Base.transaction do
      tournament = Tournament.create(tournament_type: :elimination)
      @elimination = tournament.build_elimination(elimination_params)
      num_of_teams = params[:num_of_teams].to_i

      if @elimination.save
        (1..num_of_teams).each do |i|
          @elimination.teams.create(name: "Team#{i}", entryNo: i)
        end
        redirect_to elimination_path(@elimination)
      else
        render 'new', status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  def edit
    @elimination = Elimination.find_by(id: params[:id])
    unless @elimination
      flash[:warning] = "トーナメントが見つかりません。"
      redirect_to root_path and return
    end
  end

  def update
    @elimination = Elimination.find_by(id: params[:id])

    if @elimination.update(elimination_params)
      redirect_to elimination_path(@elimination)
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    @elimination = Elimination.find_by(id: params[:id])
    @elimination.tournament.destroy

    redirect_to root_path, flash: { info: 'トーナメントを削除しました' }
  end

  def reset
    @elimination = Elimination.find_by(id: params[:id])
    @elimination.games.delete_all

    redirect_to elimination_path, flash: { info: 'トーナメントをリセットしました' }
  end

  def share
    @elimination = Elimination.find_by(id: params[:id])
  end

  ### Private Method

  private

  def elimination_params
    params.require(:elimination).permit(:name)
  end
end
