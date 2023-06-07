class GamesController < ApplicationController
  include EliminationsHelper

  def new
    @elimination = Elimination.find_by(id: params[:elimination_id])
    @game = @elimination.games.new

    set_game_param
  end

  def create
    @elimination = Elimination.find_by(id: params[:elimination_id])

    @game = @elimination.games.new(game_params)
    # 更新成功確認
    if !(@game.save)
      render 'form_update', status: :unprocessable_entity and return
    end

    redirect_to elimination_path(@elimination)
  end

  def edit
    @elimination = Elimination.find_by(id: params[:elimination_id])
    @game = Game.find_by(id: params[:id])

    set_game_param
  end

  def update
    @elimination = Elimination.find_by(id: params[:elimination_id])
    @game = Game.find_by(id: params[:id])

    # 更新成功確認
    if !(@game.update(game_params))
      render 'form_update', status: :unprocessable_entity and return
    end

    redirect_to elimination_path(@elimination)
  end

  def destroy
    @elimination = Elimination.find_by(id: params[:elimination_id])
    @game = Game.find_by(id: params[:id])

    @game.destroy
    redirect_to elimination_path(@elimination), status: :see_other
  end

  ### Private Method

  private

  def set_game_param
    teams = @elimination.teams.map(&:attributes)
    games = @elimination.games.map(&:attributes)

    round = params[:round].to_i
    gameNo = params[:gameNo].to_i
    seed_table = @elimination.seed_table
    @game.round = round
    @game.gameNo = gameNo
    a_team = get_team_from_game(round:, gameNo:, side: 'a', teams:, games:, seed_table:)
    b_team = get_team_from_game(round:, gameNo:, side: 'b', teams:, games:, seed_table:)
    @game.a_team_id = a_team ? a_team["id"] : nil
    @game.b_team_id = b_team ? b_team["id"] : nil
  end

  def game_params

    a_team_id = params[:game][:a_team_id]
    b_team_id = params[:game][:b_team_id]
    win_team_id = params[:game][:win_team_id]

    if win_team_id == a_team_id
      lose_team_id = b_team_id
      a_result = 'WIN'
      b_result = 'LOSE'
    elsif win_team_id == b_team_id
      lose_team_id = a_team_id
      a_result = 'LOSE'
      b_result = 'WIN'
    end

    params.require(:game).permit(:round, :gameNo, :a_team_id, :b_team_id, :win_team_id)
          .merge(lose_team_id:, a_result:, b_result:)
  end

end
