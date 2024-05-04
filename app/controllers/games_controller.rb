class GamesController < ApplicationController
  before_action :authenticate_owner

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
      elimination = @tournament.elimination
      @elimination = EliminationDecorator.new(elimination)
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
      elimination = @tournament.elimination
      @elimination = EliminationDecorator.new(elimination)
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
      elimination = @tournament.elimination
      @elimination = EliminationDecorator.new(elimination)
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
    round = params[:round].to_i
    gameNo = params[:gameNo].to_i
    @game.round = round
    @game.gameNo = gameNo

    elimination = EliminationDecorator.new(@tournament.elimination)
    a_team = elimination.get_team_by_game(round:, gameNo:, side: 'a')
    b_team = elimination.get_team_by_game(round:, gameNo:, side: 'b')
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

  def authenticate_owner
    tournament = Tournament.find_by(id: params[:tournament_id])
    unless view_context.tournament_owner?(tournament)
      if tournament.elimination?
        redirect_to elimination_draw_path(tournament.elimination)
      else
        redirect_to roundrobin_draw_path(tournament.roundrobin)
      end
    end
  end

end
