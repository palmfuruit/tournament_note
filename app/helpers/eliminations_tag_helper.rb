module EliminationsTagHelper

  def th_tags__round_badge(round_offset:, final_round:)
    round_badge_ths = []

    (round_offset + 1..final_round).each do |i|
      round_badge_ths << th_tag__round_badge(round: i, final_round:)
    end

    round_badge_ths
  end

  def th_tag__round_badge(round:, final_round:)
    str_round = case round
                when final_round
                  "決勝"
                when final_round - 1
                  "準決勝"
                  # when PLAYOFF_ROUND
                  #   "3位決定戦"
                else
                  "#{round}回戦"
                end
    tag.th do
      concat tag.div str_round, class: ["badge bg-dark"]
    end
  end

  def span_tag__status(elimination)
    case elimination.status
    when 'NOT_STARTED'
      tag.span '開始前', class: ["badge border border-main text-main"]
    when 'ONGOING'
      tag.span '進行中', class: ["badge bg-main"]
    when 'FINISHED'
      tag.span '終了', class: ["badge bg-secondary"]
    end
  end

  def td_tags__team_name(teams:, games:, round_offset:, seed_table:, final_round:)
    round = 1 + round_offset
    max = 2 ** (final_round - round)
    team_i = 1
    tag__tds_entryNo = []
    tag__tds_team_name = []

    1.upto(max) do |i|
      team1 = get_team_from_game(round:, gameNo: i, side: 'a', teams:, games:, seed_table:)
      team2 = get_team_from_game(round:, gameNo: i, side: 'b', teams:, games:, seed_table:)

      if round >= 2 || (team1 && team2)

        tag__tds_entryNo << tag.td(class: 'team align-middle', rowspan: "2") { div_tag__team_entryNo(team1) }
        tag__tds_team_name << tag.td(class: 'team align-middle', rowspan: "2", data: { testid: "team#{team_i}" }) { div_tag__team_name(team1) }
        tag__tds_entryNo += Array.new(1)
        tag__tds_team_name += Array.new(1)
        team_i += 1

        tag__tds_entryNo << tag.td(class: 'team align-middle', rowspan: "2")
        tag__tds_team_name << tag.td(class: 'team align-middle', rowspan: "2")
        tag__tds_entryNo += Array.new(1)
        tag__tds_team_name += Array.new(1)

        tag__tds_entryNo << tag.td(class: 'team align-middle', rowspan: "2") { div_tag__team_entryNo(team2) }
        tag__tds_team_name << tag.td(class: 'team align-middle', rowspan: "2", data: { testid: "team#{team_i}" }) { div_tag__team_name(team2) }
        tag__tds_entryNo += Array.new(1)
        tag__tds_team_name += Array.new(1)
        team_i += 1
      else
        # 1回戦免除 (1チーム表示)
        team = team1 || team2

        tag__tds_entryNo << tag.td(class: 'team align-middle', rowspan: "2")
        tag__tds_team_name << tag.td(class: 'team align-middle', rowspan: "2")
        tag__tds_entryNo += Array.new(1)
        tag__tds_team_name += Array.new(1)

        tag__tds_entryNo << tag.td(class: 'team align-middle', rowspan: "2") { div_tag__team_entryNo(team) }
        tag__tds_team_name << tag.td(class: 'team align-middle', rowspan: "2", data: { testid: "team#{team_i}" }) { div_tag__team_name(team) }
        tag__tds_entryNo += Array.new(1)
        tag__tds_team_name += Array.new(1)
        team_i += 1

        tag__tds_entryNo << tag.td(class: 'team align-middle', rowspan: "2")
        tag__tds_team_name << tag.td(class: 'team align-middle', rowspan: "2")
        tag__tds_entryNo += Array.new(1)
        tag__tds_team_name += Array.new(1)
      end

      if i < max
        tag__tds_entryNo << tag.td(class: 'team align-middle', rowspan: "2")
        tag__tds_team_name << tag.td(class: 'team align-middle', rowspan: "2")
        tag__tds_entryNo += Array.new(1)
        tag__tds_team_name += Array.new(1)
      end
    end

    [tag__tds_entryNo, tag__tds_team_name]
  end

  def div_tag__team_entryNo(team)
    concat tag.div str_entryNo(team), class: "p-0 text-secondary"
  end

  def div_tag__team_name(team)
    concat tag.div team_name(team), class: "p-0 bg-primary-subtle"
  end

  def td_tags__round(elimination:, games:, round_offset:, final_round:, seed_table:)
    round_tds = []
    max = final_round - round_offset

    round_tds << td_tags__1st_round(elimination:, games:, round_offset:, final_round:, seed_table:)
    (2..max).each do |round|
      round_tds << td_tags__Nth_round(elimination:, games:, round:, round_offset:, final_round:, seed_table:)
    end

    round_tds
  end

  def td_tags__1st_round(elimination:, games:, round_offset:, final_round:, seed_table:)
    round = 1 + round_offset
    max = num_of_Nth_round_games(round:, final_round:)
    tag__tds = []

    if max == 1
      # 2回戦がない (全部で2チーム)
      game = game(games:, round:, gameNo: 1)
      tag__tds << tag.td
      tag__tds << tag.td(class: ["game-cell b-top b-right b-bottom", border_top_bottom__a_win_b_win(game)], rowspan: "4") { game_cell_content(elimination:, games:, round:, gameNo: 1) }
      tag__tds += Array.new(3)
      tag__tds << tag.td
    else
      1.upto(max) { |i|
        gameNo1 = (i * 2) - 1
        gameNo2 = i * 2
        game1_exist = exist_first_game?(1, gameNo1, seed_table)
        game2_exist = exist_first_game?(1, gameNo2, seed_table)
        game1 = game(games:, round:, gameNo: gameNo1)
        game2 = game(games:, round:, gameNo: gameNo2)

        next_round = 2
        next_gameNo = gameNo2 / 2
        next_game = game(games:, round: next_round, gameNo: next_gameNo)

        if (round_offset >= 1 || (game1_exist && game2_exist))
          # 2試合ともあり。
          tag__tds << tag.td
          tag__tds << tag.td(class: ["game-cell b-top b-right b-bottom", border_top_bottom__a_win_b_win(game1)], rowspan: "4") { game_cell_content(elimination:, games:, round:, gameNo: gameNo1) }
          tag__tds += Array.new(3)

          tag__tds << tag.td(rowspan: "4")
          tag__tds += Array.new(3)

          tag__tds << tag.td(class: ["game-cell b-top b-right b-bottom", border_top_bottom__a_win_b_win(game2)], rowspan: "4") { game_cell_content(elimination:, games:, round:, gameNo: gameNo2) }
          tag__tds += Array.new(3)

          tag__tds << tag.td
        elsif (!game1_exist && game2_exist)
          # 上は試合なし。下は試合あり。
          tag__tds << tag.td(rowspan: "3")
          tag__tds += Array.new(2)

          tag__tds << tag.td(class: ["game-cell b-top", border_top__a_win(next_game)], rowspan: "6") { game_cell_content(elimination:, games:, round: next_round, gameNo: next_gameNo) }
          tag__tds += Array.new(5)

          tag__tds << tag.td(class: ["game-cell b-top b-right b-bottom", border_top_bottom__a_win_b_win(game2)], rowspan: "4") { game_cell_content(elimination:, games:, round:, gameNo: gameNo2) }
          tag__tds += Array.new(3)

          tag__tds << tag.td
        elsif (game1_exist && !game2_exist)
          # 上は試合あり。下は試合なし。
          tag__tds << tag.td
          tag__tds << tag.td(class: ["game-cell b-top b-right b-bottom", border_top_bottom__a_win_b_win(game1)], rowspan: "4") { game_cell_content(elimination:, games:, round:, gameNo: gameNo1) }
          tag__tds += Array.new(3)

          tag__tds << tag.td(class: ["game-cell b-bottom", border_bottom__b_win(next_game)], rowspan: "6") { game_cell_content(elimination:, games:, round: next_round, gameNo: next_gameNo) }
          tag__tds += Array.new(5)

          tag__tds << tag.td(rowspan: "3")
          tag__tds += Array.new(2)
        else
          # 2試合ともなし
          tag__tds << tag.td(rowspan: "3")
          tag__tds += Array.new(2)

          next_round = 2
          next_gameNo = gameNo2 / 2
          tag__tds << tag.td(class: ["game-cell b-top b-bottom", border_top_bottom__a_win_b_win(next_game)], rowspan: "8") { game_cell_content(elimination:, games:, round: next_round, gameNo: next_gameNo) }
          tag__tds += Array.new(7)

          tag__tds << tag.td(rowspan: "3")
          tag__tds += Array.new(2)
        end

        if (i < max)
          tag__tds << tag.td(rowspan: "2")
          tag__tds += Array.new(1)
        end
      }
    end

    tag__tds
  end

  def td_tags__Nth_round(elimination:, games:, round:, round_offset:, final_round:, seed_table:)
    # 3回戦までない場合は何も返さない。
    return [] if final_round < round

    max = num_of_Nth_round_games(round:, final_round:)
    prev_round = round - 1
    tag__tds = []

    1.upto(max) do |i|
      prev_game1 = game(games:, round: prev_round, gameNo: (i * 2) - 1)
      prev_game2 = game(games:, round: prev_round, gameNo: i * 2)
      this_game = game(games:, round:, gameNo: i)

      width1 = (2 ** (round - round_offset - 1) - 1)
      width2 = (2 ** (round - round_offset - 1))
      width3 = (2 ** (round - round_offset))

      # 外
      tag__tds << tag.td(rowspan: width1.to_s)
      tag__tds += Array.new(width1 - 1)

      # Prev1 A-Win
      tag__tds << tag.td(a_score(prev_game1), class: border_left_bottom__a_win(prev_game1), rowspan: width2.to_s)
      tag__tds += Array.new(width2 - 1)

      # Prev1 B-Win
      tag__tds << tag.td(class: ["game-cell b-top b-right", border_left_top__b_win(prev_game1), border_top__a_win(this_game)], rowspan: width2.to_s) { game_cell_content(elimination:, games:, round:, gameNo: i, score: b_score(prev_game1)) }
      tag__tds += Array.new(width2 - 1)

      # 内
      tag__tds << tag.td(class: "game-cell b-right", rowspan: width3.to_s) { game_cell_content(elimination:, games:, round:, gameNo: i) }
      tag__tds += Array.new(width3 - 1)

      # Prev2 A-Win
      tag__tds << tag.td(class: ["game-cell b-bottom b-right", border_left_bottom__a_win(prev_game2), border_bottom__b_win(this_game)], rowspan: width2.to_s) { game_cell_content(elimination:, games:, round:, gameNo: i, score: a_score(prev_game2)) }
      tag__tds += Array.new(width2 - 1)

      # Prev2 B-Win
      tag__tds << tag.td(b_score(prev_game2), class: border_left_top__b_win(prev_game2), rowspan: width2.to_s)
      tag__tds += Array.new(width2 - 1)

      # 外
      tag__tds << tag.td(rowspan: width1.to_s)
      tag__tds += Array.new(width1 - 1)

      if (i < max)
        tag__tds << tag.td(rowspan: "2")
        tag__tds += Array.new(1)
      end
    end

    tag__tds
  end

  def tr_tag__final_round_score(elimination:, games:, round_offset:, final_round:, seed_table:)
    score_cell_size = 2 ** (final_round - round_offset)
    space_cell_size = score_cell_size - 1
    final_game = game(games:, round: final_round, gameNo: 1)
    tag__tds = []

    tag__tds << tag.td(rowspan: space_cell_size)
    tag__tds += Array.new(space_cell_size - 1)

    tag__tds << tag.td(a_score(final_game), class: ["b-bottom", border_left_bottom__a_win(final_game)], rowspan: score_cell_size)
    tag__tds += Array.new(score_cell_size - 1)

    tag__tds << tag.td(b_score(final_game), class: ["b-top", border_left_top__b_win(final_game)], rowspan: score_cell_size)
    tag__tds += Array.new(score_cell_size - 1)

    tag__tds << tag.td(rowspan: space_cell_size)
    tag__tds += Array.new(space_cell_size - 1)

    tag__tds
  end

  def tr_tag__winning_cup(round_offset:, final_round:)
    winningcup_cell_size = 2 ** (final_round - round_offset) * 2
    space_cell_size = (winningcup_cell_size / 2) - 1
    tag__tds = []

    tag__tds << tag.td(rowspan: space_cell_size)
    tag__tds += Array.new(space_cell_size - 1)

    tag__tds << tag.td(class: ['winning_cup', 'align-middle'], rowspan: winningcup_cell_size) do
      concat image_tag('gold_trophy.png', width: '100%')
    end
    tag__tds += Array.new(winningcup_cell_size - 1)

    tag__tds << tag.td(rowspan: space_cell_size)
    tag__tds += Array.new(space_cell_size - 1)

    tag__tds
  end

end
