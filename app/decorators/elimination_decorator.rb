class EliminationDecorator < ApplicationDecorator
  delegate_all

  attr_reader :teams, :games

  def initialize(object)
    super(object)
    @teams = elimination.teams.order(:entryNo).map(&:attributes)
    @games = elimination.games.map(&:attributes)
    @round_offset = 0
    @final_round = final_round
    @seed_table = seed_table
  end

  def th_tags__round_badge
    round_badge_ths = []

    (@round_offset + 1..@final_round).each do |i|
      round_badge_ths << th_tag__round_badge(round: i)
    end

    round_badge_ths
  end

  def get_team_by_game(round:, gameNo:, side:)
    team = nil

    # 1, 2回戦は、各チームの初戦をチェック。
    if [1, 2].include?(round)
      case round
        when 1
          team_entryNo =@seed_table.find_index { |n| n[:round1_gameNo] == gameNo && n[:round1_side] == side }
          team = @teams.find { |n| n["entryNo"] == team_entryNo + 1 } if team_entryNo
        when 2
          if @seed_table.select { |n| n[:round2_gameNo] == gameNo && n[:round2_side] == side }.count == 1
            team_entryNo = @seed_table.find_index { |n| n[:round2_gameNo] == gameNo && n[:round2_side] == side }
            team = @teams.find { |n| n["entryNo"] == team_entryNo + 1 } if team_entryNo
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
      #     team = @teams.find { |n| n["id"] == team_id } if team_id
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
        team = @teams.find { |n| n["id"] == team_id } if team_id
      end
      # end

    end

    team
  end

  def td_tags__team_name
    round = 1 + @round_offset
    max = 2 ** (@final_round - round)
    team_i = 1
    tag__tds_entryNo = []
    tag__tds_team_name = []

    1.upto(max) do |i|
      team1 = get_team_by_game(round:, gameNo: i, side: 'a')
      team2 = get_team_by_game(round:, gameNo: i, side: 'b')

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

  def td_tags__round
    round_tds = []
    max = @final_round - @round_offset

    round_tds << td_tags__1st_round
    (2..max).each do |round|
      round_tds << td_tags__Nth_round(round:)
    end

    round_tds
  end


  def tr_tag__final_round_score
    score_cell_size = 2 ** (@final_round - @round_offset)
    space_cell_size = score_cell_size - 1
    final_game = game(games:, round: @final_round, gameNo: 1)
    tag__tds = []

    tag__tds << tag.td(rowspan: space_cell_size)
    tag__tds += Array.new(space_cell_size - 1)

    testid_score = (final_game) ? "#{@final_round}-1-a-score" : nil
    tag__tds << tag.td(a_score_str(final_game), class: ['score', 'a-score-cell', "b-bottom", 'b-left', border_left_bottom__a_win(final_game)], rowspan: score_cell_size, data: { testid: testid_score })
    tag__tds += Array.new(score_cell_size - 1)

    testid_score = (final_game) ? "#{@final_round}-1-b-score" : nil
    tag__tds << tag.td(b_score_str(final_game), class: ['score', 'b-score-cell', "b-top", 'b-left', border_left_top__b_win(final_game)], rowspan: score_cell_size, data: { testid: testid_score })
    tag__tds += Array.new(score_cell_size - 1)

    tag__tds << tag.td(rowspan: space_cell_size)
    tag__tds += Array.new(space_cell_size - 1)

    tag__tds
  end

  def tr_tag__winning_cup
    winningcup_cell_size = (2 ** (@final_round - @round_offset)) * 2
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

  def table_row_size
    (2 ** (@final_round - @round_offset + 2)) - 2
  end


  private
  def th_tag__round_badge(round:)
    str_round = case round
                  when @final_round
                    "決勝"
                  when @final_round - 1
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

  def div_tag__team_entryNo(team)
    str = team ? team['entryNo'].to_s : ""

    concat tag.div(str, class: "p-0 text-secondary")
  end

  def div_tag__team_name(team)
    concat tag.div(class: "p-0 team-name-cell") {
      concat team_uniform(team)
      concat " "
      concat team_name(team)
    }
  end



  def td_tags__1st_round
    round = 1 + @round_offset
    max = num_of_Nth_round_games(round:)
    tag__tds = []

    if max == 1
      # 2回戦がない (全部で2チーム)
      game = game(games:, round:, gameNo: 1)
      testid_game = "#{round}-1-game"

      tag__tds << tag.td
      tag__tds << tag.td(class: ["game-cell b-top b-bottom", border_top_bottom__a_win_b_win(game)], rowspan: "4", data: { testid: "#{testid_game}" }) { game_cell(round:, gameNo: 1) }
      tag__tds += Array.new(3)
      tag__tds << tag.td
    else
      1.upto(max) { |i|
        gameNo1 = (i * 2) - 1
        gameNo2 = i * 2
        game1_exist = exist_first_game?(1, gameNo1)
        game2_exist = exist_first_game?(1, gameNo2)
        game1 = game(games:, round:, gameNo: gameNo1)
        game2 = game(games:, round:, gameNo: gameNo2)
        testid_game1 = "#{round}-#{gameNo1}-game"
        testid_game2 = "#{round}-#{gameNo2}-game"

        next_round = 2
        next_gameNo = gameNo2 / 2
        next_game = game(games:, round: next_round, gameNo: next_gameNo)
        testid_next_game = "#{next_round}-#{next_gameNo}-game"

        if (@round_offset >= 1 || (game1_exist && game2_exist))
          # 2試合ともあり。
          tag__tds << tag.td
          tag__tds << tag.td(class: ["game-cell b-top", border_top__a_win(game1)], data: { testid: "#{testid_game1}_top" }) { game_cell(round:, gameNo: gameNo1) }
          tag__tds << tag.td(class: ["game-cell"], data: { testid: "#{testid_game1}" }) { game_cell(round:, gameNo: gameNo1) }
          tag__tds << tag.td(class: ["game-cell"], data: { testid: "#{testid_game1}" }) { game_cell(round:, gameNo: gameNo1) }
          tag__tds << tag.td(class: ["game-cell b-bottom", border_bottom__b_win(game1)], data: { testid: "#{testid_game1}_bottom" }) { game_cell(round:, gameNo: gameNo1) }

          tag__tds << tag.td(rowspan: "4")
          tag__tds += Array.new(3)

          tag__tds << tag.td(class: ["game-cell b-top", border_top__a_win(game2)], data: { testid: "#{testid_game2}_top" }) { game_cell(round:, gameNo: gameNo2) }
          tag__tds << tag.td(class: ["game-cell"], data: { testid: "#{testid_game2}" }) { game_cell(round:, gameNo: gameNo2) }
          tag__tds << tag.td(class: ["game-cell"], data: { testid: "#{testid_game2}" }) { game_cell(round:, gameNo: gameNo2) }
          tag__tds << tag.td(class: ["game-cell b-bottom", border_bottom__b_win(game2)], data: { testid: "#{testid_game2}_bottom" }) { game_cell(round:, gameNo: gameNo2) }

          tag__tds << tag.td
        elsif (!game1_exist && game2_exist)
          # 上は試合なし。下は試合あり。
          tag__tds << tag.td(rowspan: "3")
          tag__tds += Array.new(2)

          tag__tds << tag.td(class: ["game-cell b-top", border_top__a_win(next_game)], rowspan: "6", data: { testid: "#{testid_next_game}" }) { game_cell(round: next_round, gameNo: next_gameNo) }
          tag__tds += Array.new(5)

          tag__tds << tag.td(class: ["game-cell b-top", border_top__a_win(game2)], data: { testid: "#{testid_game2}_top" }) { game_cell(round:, gameNo: gameNo2) }
          tag__tds << tag.td(class: ["game-cell"], data: { testid: "#{testid_game2}" }) { game_cell(round:, gameNo: gameNo2) }
          tag__tds << tag.td(class: ["game-cell"], data: { testid: "#{testid_game2}" }) { game_cell(round:, gameNo: gameNo2) }
          tag__tds << tag.td(class: ["game-cell b-bottom", border_bottom__b_win(game2)], data: { testid: "#{testid_game2}_bottom" }) { game_cell(round:, gameNo: gameNo2) }

          tag__tds << tag.td
        elsif (game1_exist && !game2_exist)
          # 上は試合あり。下は試合なし。
          tag__tds << tag.td
          tag__tds << tag.td(class: ["game-cell b-top", border_top__a_win(game1)], data: { testid: "#{testid_game1}_top" }) { game_cell(round:, gameNo: gameNo1) }
          tag__tds << tag.td(class: ["game-cell"], data: { testid: "#{testid_game1}" }) { game_cell(round:, gameNo: gameNo1) }
          tag__tds << tag.td(class: ["game-cell"], data: { testid: "#{testid_game1}" }) { game_cell(round:, gameNo: gameNo1) }
          tag__tds << tag.td(class: ["game-cell b-bottom", border_bottom__b_win(game1)], data: { testid: "#{testid_game1}_bottom" }) { game_cell(round:, gameNo: gameNo1) }

          tag__tds << tag.td(class: ["game-cell b-bottom", border_bottom__b_win(next_game)], rowspan: "6", data: { testid: "#{testid_next_game}" }) { game_cell(round: next_round, gameNo: next_gameNo) }
          tag__tds += Array.new(5)

          tag__tds << tag.td(rowspan: "3")
          tag__tds += Array.new(2)
        else
          # 2試合ともなし
          tag__tds << tag.td(rowspan: "3")
          tag__tds += Array.new(2)

          next_round = 2
          next_gameNo = gameNo2 / 2
          tag__tds << tag.td(class: ["game-cell b-top b-bottom", border_top_bottom__a_win_b_win(next_game)], rowspan: "8", data: { testid: "#{testid_next_game}" }) { game_cell(round: next_round, gameNo: next_gameNo) }
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

  def td_tags__Nth_round(round:)
    # 3回戦までない場合は何も返さない。
    return [] if @final_round < round

    max = num_of_Nth_round_games(round:)
    prev_round = round - 1
    tag__tds = []

    1.upto(max) do |i|
      prev_game1_gameNo = (i * 2) - 1
      prev_game2_gameNo = (i * 2)
      prev_game1 = game(games:, round: prev_round, gameNo: prev_game1_gameNo)
      prev_game2 = game(games:, round: prev_round, gameNo: prev_game2_gameNo)
      this_game = game(games:, round:, gameNo: i)
      testid_game = "#{round}-#{i}-game"

      width1 = ((2 ** (round - @round_offset - 1)) - 1)
      width2 = (2 ** (round - @round_offset - 1))
      width3 = (2 ** (round - @round_offset))

      # 外
      tag__tds << tag.td(rowspan: width1.to_s)
      tag__tds += Array.new(width1 - 1)

      # Prev1 A-Win
      unless is_first_game?(round:, gameNo: i, side: 'a')
        b_left = 'b-left'
      else
        b_left = ''
      end

      testid_score = (prev_game1) ? "#{prev_round}-#{prev_game1_gameNo}-a-score" : nil
      tag__tds << tag.td(a_score_str(prev_game1), class: ['score', 'a-score-cell', b_left, border_left_bottom__a_win(prev_game1)], rowspan: width2.to_s, data: { testid: testid_score })
      tag__tds += Array.new(width2 - 1)

      # Prev1 B-Win
      testid_score = (prev_game1) ? "#{prev_round}-#{prev_game1_gameNo}-b-score" : nil
      tag__tds << tag.td(class: ["b-score-cell game-cell b-top", b_left, border_left_top__b_win(prev_game1), border_top__a_win(this_game)], rowspan: width2.to_s, data: { testid: "#{testid_game} #{testid_score}" }) {
        game_cell(round:, gameNo: i, score: b_score_str(prev_game1))
      }
      tag__tds += Array.new(width2 - 1)

      # 内
      width3.times do
        tag__tds << tag.td(class: "game-cell", data: { testid: "#{testid_game}" }) { game_cell(round:, gameNo: i) }
      end

      # Prev2 A-Win
      unless is_first_game?(round:, gameNo: i, side: 'b')
        b_left = 'b-left'
      else
        b_left = ''
      end

      testid_score = (prev_game2) ? "#{prev_round}-#{prev_game2_gameNo}-a-score" : nil
      tag__tds << tag.td(class: ["a-score-cell game-cell b-bottom", b_left, border_left_bottom__a_win(prev_game2), border_bottom__b_win(this_game)], rowspan: width2.to_s, data: { testid: "#{testid_game} #{testid_score}" }) {
        game_cell(round:, gameNo: i, score: a_score_str(prev_game2))
      }
      tag__tds += Array.new(width2 - 1)

      # Prev2 B-Win
      testid_score = (prev_game2) ? "#{prev_round}-#{prev_game2_gameNo}-b-score" : nil
      tag__tds << tag.td(b_score_str(prev_game2), class: ['score', 'b-score-cell', b_left, border_left_top__b_win(prev_game2)], rowspan: width2.to_s, data: { testid: testid_score })
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

  def game_cell(round:, gameNo:, score: nil)
    this_game = game(games: @games, round:, gameNo:)
    str_class = score ? 'score' : nil

    if this_game
      path = edit_tournament_game_path(tournament, this_game["id"], round:, gameNo:)
    else
      path = new_tournament_game_path(tournament, round:, gameNo:)
    end

    if tournament_owner?(tournament)
      tag.a(href: path, class: str_class, data: { turbo_frame: "modal" }) {
        score
      }
    else
      tag.div(class: str_class) {
        score
      }
    end

  end

  def num_of_Nth_round_games(round:)
    (round <= @final_round) ? (2 ** (@final_round - round)) : 0
  end

  def is_first_game?(round:, gameNo:, side:)
    if round == 1
      ret = true
    elsif round == 2
      ret = @seed_table.select { |n| n[:round2_gameNo] == gameNo && n[:round2_side] == side }.count == 1
    else
      ret = false
    end
    ret
  end

  def exist_first_game?(round, gameNo)
    case round
      when 1
        count = @seed_table.select { |n| n[:round1_gameNo] == gameNo }.count
        count == 2
      when 2
        count = @seed_table.select { |n| n[:round2_gameNo] == gameNo }.count
        count == 2
      else
        false
    end
  end

end
