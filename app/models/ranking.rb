class Ranking
  include Draper::Decoratable

  attr_reader :teams, :roundrobin

  def initialize(roundrobin)
    @roundrobin = roundrobin
    @teams = @roundrobin.teams.order(:entryNo).map(&:attributes)
    @games = @roundrobin.games.map(&:attributes)
    @ranking = rank(teams: @teams, games: @games, ranking_criteria: [@roundrobin.rank1, @roundrobin.rank2, @roundrobin.rank3, @roundrobin.rank4])
  end

  def get
    @ranking
  end

  def has_score
    @roundrobin.has_score
  end

  def rank_by?(criteria)
    (@roundrobin.rank1 == criteria || @roundrobin.rank2 == criteria || @roundrobin.rank3 == criteria || @roundrobin.rank4 == criteria) ? true : false
  end


  ### Private Method
  private

  def rank(teams:, games:, ranking_criteria:)
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
    ranking_criteria.each_with_index do |criteria, i|
      next if criteria == 'none'

      rank_with_multi_teams = ranking.map { |team| team['rank'] }
      rank_with_multi_teams = rank_with_multi_teams.select { |e| rank_with_multi_teams.count(e) > 1 }.uniq
      next if rank_with_multi_teams.empty?

      rank_with_multi_teams.each do |rank|
        ranking_parts = ranking.select { |team| team['rank'] == rank }

        if criteria == 'head_to_head'
          # 直接対決
          sub_team_ids = ranking_parts.map { |st| st['team_id'] }
          sub_teams = teams.select { |st| sub_team_ids.include?(st['id']) }
          sub_ranking = rank(teams: sub_teams, games: games, ranking_criteria: ranking_criteria[0..i - 1])
          ranking_parts.each do |team|
            team['rank'] += sub_ranking.find { |sr| sr['team_id'] == team['team_id'] }['rank'] - 1
          end
        else
          # 直接対決以外
          ranking_parts.sort_by! { |team| -team[criteria] }
          (1..ranking_parts.size - 1).each do |j|
            if (ranking_parts[j - 1][criteria] == ranking_parts[j][criteria])
              ranking_parts[j]['rank'] = ranking_parts[j - 1]['rank']
            else
              ranking_parts[j]['rank'] = rank + j
            end
          end
        end

        ranking.sort_by! { |team| team['rank'] }
      end

      # logger.debug("=====================================")
      # logger.debug("criteria: (#{i}) #{criteria}")
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

end