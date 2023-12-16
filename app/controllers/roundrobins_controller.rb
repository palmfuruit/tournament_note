class RoundrobinsController < ApplicationController
  before_action :authenticate_owner, only: [:edit, :update, :destroy, :reset]

  def index
    @num_of_roundrobins = Roundrobin.all.size
    @roundrobins = Roundrobin.all.order(created_at: :desc).page(params[:page])
  end

  def show
    @roundrobin = Roundrobin.find_by(id: params[:id])
    unless @roundrobin
      flash[:warning] = "リーグが見つかりません。"
      redirect_to root_path and return
    end

    @teams = @roundrobin.teams.order(:entryNo).map(&:attributes)
    @games = @roundrobin.games.map(&:attributes)
    @round = 1
  end

  def change_round
    @roundrobin = Roundrobin.find_by(id: params[:id])
    @round = params[:round].to_i

    unless @roundrobin
      flash[:warning] = "リーグが見つかりません。"
      redirect_to root_path and return
    end

    @teams = @roundrobin.teams.order(:entryNo).map(&:attributes)
    @games = @roundrobin.games.map(&:attributes)
  end

  def ranking
    @roundrobin = Roundrobin.find_by(id: params[:id])
    unless @roundrobin
      flash[:warning] = "リーグが見つかりません。"
      redirect_to root_path and return
    end

    @teams = @roundrobin.teams.order(:entryNo).map(&:attributes)
    @games = @roundrobin.games.map(&:attributes)
    @ranking = rank(teams: @teams, games: @games, rank_conditions: [@roundrobin.rank1, @roundrobin.rank2, @roundrobin.rank3, @roundrobin.rank4])
  end

  def new
    @roundrobin = Roundrobin.new()
  end

  def create
    ActiveRecord::Base.transaction do
      tournament = Tournament.create(tournament_type: :roundrobin)
      @roundrobin = tournament.build_roundrobin(roundrobin_params)
      num_of_teams = params[:num_of_teams].to_i

      if @roundrobin.save
        set_cookie(@roundrobin.id, @roundrobin.password, 'roundrobin')

        (1..num_of_teams).each do |i|
          @roundrobin.teams.create(name: "Team#{i}", entryNo: i)
        end
        redirect_to roundrobin_path(@roundrobin)
      else
        render 'new', status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  def edit
    @roundrobin = Roundrobin.find_by(id: params[:id])
    unless @roundrobin
      flash[:warning] = "リーグが見つかりません。"
      redirect_to root_path and return
    end
  end

  def update
    @roundrobin = Roundrobin.find_by(id: params[:id])

    if @roundrobin.update(roundrobin_params)
      set_cookie(@roundrobin.id, @roundrobin.password, 'roundrobin')

      redirect_to roundrobin_path(@roundrobin)
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    @roundrobin = Roundrobin.find_by(id: params[:id])
    @roundrobin.tournament.destroy
    clear_cookie(@roundrobin.id, 'roundrobin')

    redirect_to root_path, flash: { info: 'リーグを削除しました' }
  end

  def reset
    @roundrobin = Roundrobin.find_by(id: params[:id])
    @roundrobin.games.delete_all

    redirect_to roundrobin_path(@roundrobin), flash: { info: 'リーグをリセットしました' }
  end

  def share
    @roundrobin = Roundrobin.find_by(id: params[:id])
  end

  def admin
    @roundrobin = Roundrobin.find_by(id: params[:id])
  end

  def authentication
    @roundrobin = Roundrobin.find_by(id: params[:id])
    unless @roundrobin
      flash[:warning] = "リーグが見つかりません。"
      redirect_to root_path and return
    end

    @error_message = nil
    if @roundrobin.password == params[:password]
      set_cookie(@roundrobin.id, params[:password], 'roundrobin')

      redirect_to roundrobin_path(@roundrobin)
    else
      @error_message = "パスワードが不一致です"

      render 'admin', status: :unprocessable_entity
    end

  end

  ### Private Method
  private

  def roundrobin_params
    ret_p = params.require(:roundrobin).permit(:name, :has_score, :num_of_round, :rank1, :rank2, :rank3, :rank4, :password)
    if ret_p[:name].blank?
      ret_p[:name] = "#{Date.today}"
    end
    ret_p
  end

  def rank(teams:, games:, rank_conditions:)
    return Array.new if teams.size == 0

    team_ids = teams.map { |team| team['id'] }
    games = games.select { |game| team_ids.include?(game['a_team_id']) && team_ids.include?(game['b_team_id']) }

    ranking = teams.map do |team|
      {
        'team_id' => team["id"],
        'rank' => 1,
        'games_count' => games_count(team["id"], games),
        'wins_count' => wins_count(team["id"], games),
        'draws_count' => draws_count(team["id"], games),
        'loses_count' => loses_count(team["id"], games),
        'total_goals' => total_goals(team["id"], games),
        'total_against_goals' => total_against_goals(team["id"], games),
      }
    end
    ranking.each do |rank|
      rank['win_points'] = (rank['wins_count'] * 3) + rank['draws_count']
      rank['win_rate'] = (rank['wins_count'] + rank['loses_count'] == 0) ? 0 : (rank['wins_count'] * 100 / (rank['wins_count'] + rank['loses_count']))
      rank['goal_diff'] = rank['total_goals'] - rank['total_against_goals']
    end

    # 優先1〜4 繰り返す
    rank_conditions.each_with_index do |rank_condition, i|
      next if rank_condition == 'none'

      rank_with_multi_teams = ranking.map { |team| team['rank'] }
      rank_with_multi_teams = rank_with_multi_teams.select { |e| rank_with_multi_teams.count(e) > 1 }.uniq
      next if rank_with_multi_teams.empty?

      rank_with_multi_teams.each do |rank|
        ranking_parts = ranking.select { |team| team['rank'] == rank }

        if rank_condition == 'head_to_head'
          # 直接対決
          sub_team_ids = ranking_parts.map { |st| st['team_id'] }
          sub_teams = teams.select { |st| sub_team_ids.include?(st['id']) }
          sub_ranking = rank(teams: sub_teams, games: games, rank_conditions: rank_conditions[0..i - 1])
          ranking_parts.each do |team|
            team['rank'] += sub_ranking.find { |sr| sr['team_id'] == team['team_id'] }['rank'] - 1
          end
        else
          # 直接対決以外
          ranking_parts.sort_by! { |team| -team[rank_condition] }
          (1..ranking_parts.size - 1).each do |j|
            if (ranking_parts[j - 1][rank_condition] == ranking_parts[j][rank_condition])
              ranking_parts[j]['rank'] = ranking_parts[j - 1]['rank']
            else
              ranking_parts[j]['rank'] = rank + j
            end
          end
        end

        ranking.sort_by! { |team| team['rank'] }
      end

      # logger.debug("=====================================")
      # logger.debug("condition: (#{i}) #{rank_condition}")
      # logger.debug("ranking: #{ranking.map { |t| { rank: t['rank'], team: teams.find { |t2| t['team_id'] == t2['id'] }['name'] } }}")
      # logger.debug("=====================================")
    end

    ranking
  end

  def games_count(team, games)
    games.count { |game| game['a_team_id'] == team || game['b_team_id'] == team }
  end

  def wins_count(team, games)
    games.count { |game| (game['a_team_id'] == team && game['a_result'] == 'WIN') || (game['b_team_id'] == team && game['b_result'] == 'WIN') }
  end

  def draws_count(team, games)
    games.count { |game| (game['a_team_id'] == team && game['a_result'] == 'DRAW') || (game['b_team_id'] == team && game['b_result'] == 'DRAW') }
  end

  def loses_count(team, games)
    games.count { |game| (game['a_team_id'] == team && game['a_result'] == 'LOSE') || (game['b_team_id'] == team && game['b_result'] == 'LOSE') }
  end

  def total_goals(team, games)
    score_a = games.select { |game| game['a_team_id'] == team }.sum { |game| game['a_score_num'] }
    score_b = games.select { |game| game['b_team_id'] == team }.sum { |game| game['b_score_num'] }
    score_a + score_b
  end

  def total_against_goals(team, games)
    score_a = games.select { |game| game['a_team_id'] == team }.sum { |game| game['b_score_num'] }
    score_b = games.select { |game| game['b_team_id'] == team }.sum { |game| game['a_score_num'] }
    score_a + score_b
  end

  def authenticate_owner
    roundrobin = Roundrobin.find_by(id: params[:id])
    unless view_context.tournament_owner?(roundrobin.tournament)
      redirect_to roundrobin_path(roundrobin)
    end
  end

end
