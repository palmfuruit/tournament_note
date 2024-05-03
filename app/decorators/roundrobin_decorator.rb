class RoundrobinDecorator < ApplicationDecorator
  delegate_all

  def round_select_contents
    (1..num_of_round).map do |i|
      games_count = roundrobin.games.count { |game| game["round"] == i }
      if games_count == 0
        { name: "Round #{i}", value: i }
      else
        { name: "Round #{i}　(#{games_count}試合)", value: i }
      end
    end
  end

  def tr_tag__team_record(teams:, games:, round:, current_team:)
    tag.tr {
      # 1列目： 自チーム名
      concat(tag.th {
        concat team_uniform(current_team)
        concat tag.div(team_name(current_team))
      })

      # 2列目〜： 各チームとの対戦結果、スコア
      teams.each do |opponent|
        if current_team == opponent
          concat tag.td(class: 'no-game-cell')
        else
          concat(tag.td(id: "game-#{current_team['entryNo']}-#{opponent['entryNo']}", class: 'game-cell') {
            game_cell(games:, round:, current_team:, opponent:)
          })
        end
      end
    }
  end

  def game_cell(games:, round: 1, current_team:, opponent:)
    class_str = ['d-flex', 'flex-column', 'justify-content-center', 'align-items-center', 'h-100']
    this_game = game(games:, round:, a_team: current_team, b_team: opponent) || game(games:, round:, a_team: opponent, b_team: current_team)


    if tournament_owner?(roundrobin.tournament)
      if this_game
        tag.a(href: edit_tournament_game_path(roundrobin.tournament, this_game["id"], round:, a_team_id: current_team["id"], b_team_id: opponent["id"]), class: class_str, data: { turbo_frame: "modal" }) {
          game_cell_content(game: this_game, current_team:)
        }
      else
        tag.a(href: new_tournament_game_path(roundrobin.tournament, round:, a_team_id: current_team["id"], b_team_id: opponent["id"]), class: class_str, data: { turbo_frame: "modal" })
      end
    else
      if this_game
        tag.div(class: class_str) {
          game_cell_content(game: this_game, current_team:)
        }
      end
    end
  end


  private

  def game_cell_content(game:, current_team:)
    if game["a_team_id"] == current_team["id"]
      game_result = game["a_result"]
      our_score = game["a_score_num"]
      thier_score = game["b_score_num"]
    else
      game_result = game["b_result"]
      our_score = game["b_score_num"]
      thier_score = game["a_score_num"]
    end

    case game_result
      when 'WIN'
        concat tag.i(class: ["bi", "bi-circle"])
      when 'DRAW'
        concat tag.i(class: ["bi", "bi-triangle"])
      when 'LOSE'
        concat tag.i(class: ["bi", "bi-circle-fill"])
    end
    if roundrobin["has_score"]
      concat tag.div(class: 'score') {
        "#{our_score} - #{thier_score}"
      }
    end
  end
end
