class RankingDecorator < ApplicationDecorator
  include ApplicationHelper

  delegate_all

  def tbody_tag__ranking
    tag.tbody {
      ranking.get.each.with_index(1) do |rank_i, i|
        concat tag.tr(data: { testid: "rank#{i}" }) {
          concat tag.td(data: { testid: "rank" }) { rank_i['rank'].to_s }
          concat tag.td(data: { testid: "team" }) {
            current_team = ranking.teams.find { |team| team["id"] == rank_i['team_id'] }
            concat team_uniform(current_team)
            concat tag.div(team_name(current_team))
          }
          concat tag.td(data: { testid: "win-points" }) { rank_i['win_points'].to_s } if ranking.rank_by?('win_points')
          concat tag.td(data: { testid: "win-rate" }) { "#{rank_i['win_rate']}%" } if ranking.rank_by?('win_rate')
          concat tag.td(data: { testid: "wins" }) { rank_i['wins_count'].to_s }
          concat tag.td(data: { testid: "draws" }) { rank_i['draws_count'].to_s }
          concat tag.td(data: { testid: "loses" }) { rank_i['loses_count'].to_s }
          if ranking.has_score
            concat tag.td(data: { testid: "total_goals" }) { rank_i['total_goals'].to_s }
            concat tag.td(data: { testid: "total_against_goals" }) { rank_i['total_against_goals'].to_s }
            concat tag.td(data: { testid: "goal_diff" }) { rank_i['goal_diff'].to_s }
          end
        }
      end
    }
  end

  def criteria1
    Roundrobin::RANKING_CRITERIA[roundrobin.rank1]
  end

  def criteria2
    Roundrobin::RANKING_CRITERIA[roundrobin.rank2]
  end

  def criteria3
    Roundrobin::RANKING_CRITERIA[roundrobin.rank3]
  end

  def criteria4
    Roundrobin::RANKING_CRITERIA[roundrobin.rank4]
  end
end
