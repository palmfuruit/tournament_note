module RoundrobinsHelper
  def tr_tag__team(roundrobin:, teams:, games:, round:, current_team:)
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
          concat tag.td(id: "game-#{current_team['entryNo']}-#{opponent['entryNo']}", class: 'game-cell') {
            roundrobin_game_cell(roundrobin:, games:, round:, current_team:, opponent:)
          }
        end
      end
    }
  end

  def roundrobin_game_cell(roundrobin:, games:, round: 1, current_team:, opponent:)
    class_str = ['d-flex', 'justify-content-center', 'align-items-center']
    this_game = game(games:, round:, a_team: current_team, b_team: opponent) || game(games:, round:, a_team: opponent, b_team: current_team)

    if !this_game
      # new
      tag.a(href: new_tournament_game_path(roundrobin.tournament, round:, a_team_id: current_team["id"], b_team_id: opponent["id"]), class: class_str, data: { turbo_frame: "modal" })
    else
      # edit
      tag.a(href: edit_tournament_game_path(roundrobin.tournament, this_game["id"], round:, a_team_id: current_team["id"], b_team_id: opponent["id"]), class: class_str, data: { turbo_frame: "modal" }) do
        game_cell_content(game: this_game, current_team:)
      end
    end
  end

  def game_cell_content(game:, current_team:)
    if game["a_team_id"] == current_team["id"]
      game_result = game["a_result"]
    else
      game_result = game["b_result"]
    end

    case game_result
      when 'WIN'
        tag.i(class: ["bi", "bi-circle"])
      when 'DRAW'
        tag.i(class: ["bi", "bi-triangle"])
      when 'LOSE'
        tag.i(class: ["bi", "bi-circle-fill"])
    end

  end

  def tbody_tag__ranking(ranking:, teams:)
    tag.tbody {
      ranking.each.with_index(1) do |rank_i, i|
        concat tag.tr(data: { testid: "rank#{i}" }) {
          concat tag.td(data: { testid: "rank" }) { rank_i['rank'].to_s }
          concat tag.td(data: { testid: "team" }) {
            current_team = teams.find { |team| team["id"] == rank_i['team_id'] }
            concat team_uniform(current_team)
            concat tag.div(team_name(current_team))
          }
          concat tag.td(data: { testid: "games" }) { rank_i['games_count'].to_s }
          concat tag.td(data: { testid: "wins" }) { rank_i['wins_count'].to_s }
          concat tag.td(data: { testid: "draws" }) { rank_i['draws_count'].to_s }
          concat tag.td(data: { testid: "loses" }) { rank_i['loses_count'].to_s }
          concat tag.td(data: { testid: "win-points" }) { rank_i['win_points'].to_s }
          concat tag.td(data: { testid: "win-rate" }) { "#{rank_i['win_rate']}%" }
        }
      end
    }
  end

  def div_tag__ranking_conditions(form:, priority:, items:)
    case priority
      when 1
        rankx_column = @roundrobin.rank1
        rankx_symbol = :rank1
        # when 2
        #   rankx_column = @roundrobin.rank2
        #   rankx_symbol = :rank2
        # when 3
        #   rankx_column = @roundrobin.rank3
        #   rankx_symbol = :rank3
        # when 4
        #   rankx_column = @roundrobin.rank4
        #   rankx_symbol = :rank4
    end

    array = items.map { |item| [Roundrobin::RANK_CONDITION[item], item] }

    tag.div(class: ['mb-3'], data: { testid: "rank-condition#{priority}" }) {
      concat(tag.div {
        concat form.label(rankx_symbol, "順位決め 優先#{priority}", class: 'form-control-label')
        concat form.select(rankx_symbol, options_for_select(array, rankx_column), {}, class: ['form-control', 'w-25'])
      })
    }

  end

  def round_select_contents
    (1..@roundrobin.num_of_round).map do |i|
      games_count = @games.count { |game| game["round"] == i }
      if games_count == 0
        { name: "Round #{i}", value: i }
      else
        { name: "Round #{i}　(#{games_count}試合)", value: i }
      end
    end
  end

end