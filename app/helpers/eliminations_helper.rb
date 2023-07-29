module EliminationsHelper

  def game(games:, round:, gameNo:)
    games.find { |game| game["round"] == round && game["gameNo"] == gameNo }
  end

  def get_team_from_game(round:, gameNo:, side:, teams:, games:, seed_table:)
    team = nil

    # 1, 2回戦は、各チームの初戦をチェック。
    if [1, 2].include?(round)
      case round
      when 1
        team_entryNo = seed_table.find_index { |n| n[:round1_gameNo] == gameNo && n[:round1_side] == side }
        team = teams.find { |n| n["entryNo"] == team_entryNo + 1 } if team_entryNo
      when 2
        if seed_table.select { |n| n[:round2_gameNo] == gameNo && n[:round2_side] == side }.count == 1
          team_entryNo = seed_table.find_index { |n| n[:round2_gameNo] == gameNo && n[:round2_side] == side }
          team = teams.find { |n| n["entryNo"] == team_entryNo + 1 } if team_entryNo
        end
      end
    end

    # 初戦じゃない場合は、前の試合の勝者をチェック
    unless team
      # if round == PLAYOFF_ROUND
      #   if side == 'a'
      #     semi_final = @games.find { |n| n["round"] == @final_round - 1 && n["gameNo"] == 1 }
      #   else
      #     semi_final = @games.find { |n| n["round"] == @final_round - 1 && n["gameNo"] == 2 }
      #   end
      #
      #   if semi_final
      #     team_id = semi_final["lose_team_id"]
      #     team = teams.find { |n| n["id"] == team_id } if team_id
      #   end
      #
      # elsif round >= 2
      if side == 'a'
        prev_gameNo = (gameNo * 2) - 1
      else
        prev_gameNo = (gameNo * 2)
      end
      prev_game = game(games:, round: round - 1, gameNo: prev_gameNo)

      if prev_game
        team_id = prev_game["win_team_id"]
        team = teams.find { |n| n["id"] == team_id } if team_id
      end
      # end

    end

    team
  end

  def str_entryNo(team)
    team ? team['entryNo'].to_s : ""
  end

  def team_name(team)
    team ? team['name'].to_s : "(未定)"
  end

  def num_of_Nth_round_games(round:, final_round:)
    (round <= final_round) ? (2 ** (final_round - round)) : 0
  end

  def border_top_bottom__a_win_b_win(game)
    if (game)
      if (game["a_result"] == 'WIN')
        "r-top"
      elsif (game["b_result"] == 'WIN')
        "r-bottom"
      end
    end
  end

  def border_top__a_win(game)
    if (game)
      if (game["a_result"] == 'WIN')
        "r-top"
      end
    end
  end

  def border_bottom__b_win(game)
    if (game)
      if (game["b_result"] == 'WIN')
        "r-bottom"
      end
    end
  end

  def border_left_bottom__a_win(game)
    if (game)
      if (game["a_result"] == 'WIN')
        "r-left r-bottom"
      end
    end
  end

  def border_left_top__b_win(game)
    if (game)
      if (game["b_result"] == 'WIN')
        "r-left r-top"
      end
    end
  end

  def game_cell_content(elimination:, games:, round:, gameNo:, score: nil)
    this_game = game(games:, round:, gameNo:)
    id_str = "#{round}-#{gameNo}-game"

    if this_game
      tag.a(href: edit_tournament_game_path(elimination.tournament, this_game["id"], round:, gameNo:), id: id_str, data: { turbo_frame: "modal" })
    else
      tag.a(href: new_tournament_game_path(elimination.tournament, round:, gameNo:), id: id_str, data: { turbo_frame: "modal" })
    end
  end

  def exist_first_game?(round, gameNo, seed_table)
    case round
    when 1
      count = seed_table.select { |n| n[:round1_gameNo] == gameNo }.count
      count == 2
    when 2
      count = seed_table.select { |n| n[:round2_gameNo] == gameNo }.count
      count == 2
    else
      false
    end
  end
end
