class GamesController < ApplicationController
  include EliminationsHelper
  include RoundrobinsHelper
  def new
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @game = @tournament.games.new

    if @tournament.elimination?
      set_elimination_game_param
    elsif @tournament.roundrobin?
      set_roundrobin_game_param
    end
  end

  def create
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @game = @tournament.games.new(game_params)

    # 更新成功確認
    if !(@game.save)
      render 'form_update', status: :unprocessable_entity and return
    end

    if @tournament.elimination?
      @elimination = @tournament.elimination
      @teams = @elimination.teams.order(:entryNo).map(&:attributes)
      @games = @elimination.games.map(&:attributes)
      render 'update_egame'
    else
      @roundrobin = @tournament.roundrobin
      @teams = @roundrobin.teams.order(:entryNo).map(&:attributes)
      @games = @roundrobin.games.map(&:attributes)
      render 'update_rgame'
    end
  end

  def edit
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @game = Game.find_by(id: params[:id])

    if @tournament.elimination?
      set_elimination_game_param
    elsif @tournament.roundrobin?
      set_roundrobin_game_param
    end
  end

  def update
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @game = Game.find_by(id: params[:id])

    # 更新成功確認
    if !(@game.update(game_params))
      render 'form_update', status: :unprocessable_entity and return
    end

    if @tournament.elimination?
      @elimination = @tournament.elimination
      @teams = @elimination.teams.order(:entryNo).map(&:attributes)
      @games = @elimination.games.map(&:attributes)
      render 'update_egame'
    else
      @roundrobin = @tournament.roundrobin
      @teams = @roundrobin.teams.order(:entryNo).map(&:attributes)
      @games = @roundrobin.games.map(&:attributes)
      render 'update_rgame'
    end
  end

  def destroy
    @tournament = Tournament.find_by(id: params[:tournament_id])
    @game = Game.find_by(id: params[:id])

    @game.destroy
    if @tournament.elimination?
      @elimination = @tournament.elimination
      @teams = @elimination.teams.order(:entryNo).map(&:attributes)
      @games = @elimination.games.map(&:attributes)
      render 'update_egame'
    else
      @roundrobin = @tournament.roundrobin
      @teams = @roundrobin.teams.order(:entryNo).map(&:attributes)
      @games = @roundrobin.games.map(&:attributes)
      render 'reset_rgame'
    end
  end

  ### Private Method

  private

  def set_elimination_game_param
    elimination = @tournament.elimination
    teams = elimination.teams.map(&:attributes)
    games = elimination.games.map(&:attributes)

    round = params[:round].to_i
    gameNo = params[:gameNo].to_i
    seed_table = elimination.seed_table
    @game.round = round
    @game.gameNo = gameNo
    a_team = get_team_from_game(round:, gameNo:, side: 'a', teams:, games:, seed_table:)
    b_team = get_team_from_game(round:, gameNo:, side: 'b', teams:, games:, seed_table:)
    @game.a_team_id = a_team ? a_team["id"] : nil
    @game.b_team_id = b_team ? b_team["id"] : nil
  end

  def set_roundrobin_game_param
    if (@game.a_team_id == params[:b_team_id]) && (@game.b_team_id == params[:a_team_id])
      @game.a_score_num, @game.b_score_num = @game.b_score_num, @game.a_score_num
      @game.a_result, @game.b_result = @game.b_result, @game.a_result
    end
    @game.round = params[:round].to_i
    @game.a_team_id = params[:a_team_id]
    @game.b_team_id = params[:b_team_id]
  end

  def game_params

    a_team_id = params[:game][:a_team_id]
    b_team_id = params[:game][:b_team_id]
    win_team_id = params[:game][:win_team_id]

    case win_team_id
      when a_team_id
        lose_team_id = b_team_id
        a_result = 'WIN'
        b_result = 'LOSE'
      when b_team_id
        lose_team_id = a_team_id
        a_result = 'LOSE'
        b_result = 'WIN'
      when "0"
        lose_team_id = '0'
        a_result = 'DRAW'
        b_result = 'DRAW'
    end


    params.require(:game).permit(:round, :gameNo, :a_team_id, :b_team_id, :win_team_id, :a_score_num, :b_score_num, :a_score_str, :b_score_str)
          .merge(lose_team_id:, a_result:, b_result:)

  end

end
