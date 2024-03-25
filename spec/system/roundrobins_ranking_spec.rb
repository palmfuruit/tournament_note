require 'rails_helper'

RSpec.describe "リーグ順位表", type: :system do

  describe "勝点/勝率" do

    let!(:roundrobin) { create(:roundrobin, :with_teams, num_of_teams: 4, rank1: :win_points) }
    before do
      teams = roundrobin.teams.order(:entryNo)
      @team1 = teams[0]
      @team2 = teams[1]
      @team3 = teams[2]
      @team4 = teams[3]

      roundrobin.games.create(round: 1, gameNo: nil, a_team: @team1, b_team: @team2, win_team: @team1, lose_team: @team2, a_result: 'WIN', b_result: 'LOSE')
      roundrobin.games.create(round: 1, gameNo: nil, a_team: @team1, b_team: @team3, win_team: @team1, lose_team: @team3, a_result: 'WIN', b_result: 'LOSE')
      roundrobin.games.create(round: 1, gameNo: nil, a_team: @team1, b_team: @team4, win_team: @team4, lose_team: @team1, a_result: 'LOSE', b_result: 'WIN')
    end

    it "順位表が正しく表示される(1:勝点)" do
      visit roundrobin_path(roundrobin)

      expect(page).to have_selector 'h1', text: roundrobin.name
      click_on '順位表'

      expect(page).to have_content "順位条件"
      expect(page).to have_content "勝点"

      within find(:test_id, 'rank1') do
        expect(find(:test_id, 'rank').text).to eq('1')
        expect(find(:test_id, 'team').text).to eq(@team1.name)
        expect(find(:test_id, 'win-points').text).to eq('6')
        expect(find(:test_id, 'wins').text).to eq('2')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('1')
      end
      within find(:test_id, 'rank2') do
        expect(find(:test_id, 'rank').text).to eq('2')
        expect(find(:test_id, 'team').text).to eq(@team4.name)
        expect(find(:test_id, 'win-points').text).to eq('3')
        expect(find(:test_id, 'wins').text).to eq('1')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('0')
      end
      within find(:test_id, 'rank3') do
        expect(find(:test_id, 'rank').text).to eq('3')
        expect(find(:test_id, 'team').text).to eq(@team2.name)
        expect(find(:test_id, 'win-points').text).to eq('0')
        expect(find(:test_id, 'wins').text).to eq('0')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('1')
      end
      within find(:test_id, 'rank4') do
        expect(find(:test_id, 'rank').text).to eq('3')
        expect(find(:test_id, 'team').text).to eq(@team3.name)
        expect(find(:test_id, 'win-points').text).to eq('0')
        expect(find(:test_id, 'wins').text).to eq('0')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('1')
      end
    end

    it "順位表が正しく表示される(1:勝率)" do
      visit roundrobin_path(roundrobin)

      expect(page).to have_selector 'h1', text: roundrobin.name

      # 順位条件を「勝率」に変更
      click_on "設定"
      expect(page).to have_button '更新'
      select '勝率', from: '順位条件1'
      click_on "更新"

      click_on '順位表'

      expect(page).to have_content "順位条件"
      expect(page).to have_content "勝率"

      within find(:test_id, 'rank1') do
        expect(find(:test_id, 'rank').text).to eq('1')
        expect(find(:test_id, 'team').text).to eq(@team4.name)
        expect(find(:test_id, 'win-rate').text).to eq('100%')
        expect(find(:test_id, 'wins').text).to eq('1')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('0')
      end
      within find(:test_id, 'rank2') do
        expect(find(:test_id, 'rank').text).to eq('2')
        expect(find(:test_id, 'team').text).to eq(@team1.name)
        expect(find(:test_id, 'win-rate').text).to eq('66%')
        expect(find(:test_id, 'wins').text).to eq('2')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('1')
      end
      within find(:test_id, 'rank3') do
        expect(find(:test_id, 'rank').text).to eq('3')
        expect(find(:test_id, 'team').text).to eq(@team2.name)
        expect(find(:test_id, 'win-rate').text).to eq('0%')
        expect(find(:test_id, 'wins').text).to eq('0')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('1')
      end
      within find(:test_id, 'rank4') do
        expect(find(:test_id, 'rank').text).to eq('3')
        expect(find(:test_id, 'team').text).to eq(@team3.name)
        expect(find(:test_id, 'win-rate').text).to eq('0%')
        expect(find(:test_id, 'wins').text).to eq('0')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('1')
      end
    end
  end

  describe "得失点差での順位判定" do

    let!(:roundrobin) { create(:roundrobin, :with_teams, num_of_teams: 3, has_score: true, rank1: :win_points) }
    before do
      @team1 = roundrobin.teams[0]
      @team2 = roundrobin.teams[1]
      @team3 = roundrobin.teams[2]

      roundrobin.games.create(round: 1, gameNo: nil, a_team: @team1, b_team: @team2, win_team: @team1, lose_team: @team2,
                              a_result: 'DRAW', b_result: 'DRAW', a_score_num: 0, b_score_num: 0)
      roundrobin.games.create(round: 1, gameNo: nil, a_team: @team1, b_team: @team3, win_team: @team1, lose_team: @team3,
                              a_result: 'WIN', b_result: 'LOSE', a_score_num: 1, b_score_num: 0)
      roundrobin.games.create(round: 1, gameNo: nil, a_team: @team2, b_team: @team3, win_team: @team2, lose_team: @team3,
                              a_result: 'WIN', b_result: 'LOSE', a_score_num: 2, b_score_num: 0)
    end

    example "1:勝点　のみ" do
      visit roundrobin_path(roundrobin)

      expect(page).to have_selector 'h1', text: roundrobin.name
      click_on '順位表'

      expect(page).to have_content "順位条件"
      expect(page).to have_content "勝点"

      # 1位が2チーム
      within find(:test_id, 'rank1') do
        expect(find(:test_id, 'rank').text).to eq('1')
        expect(find(:test_id, 'team').text).to eq(@team1.name).or eq(@team2.name)
        expect(find(:test_id, 'win-points').text).to eq('4')
        expect(find(:test_id, 'wins').text).to eq('1')
        expect(find(:test_id, 'draws').text).to eq('1')
        expect(find(:test_id, 'loses').text).to eq('0')
        expect(find(:test_id, 'total_goals').text).to eq('1')
        expect(find(:test_id, 'total_against_goals').text).to eq('0')
        expect(find(:test_id, 'goal_diff').text).to eq('1')
      end
      within find(:test_id, 'rank2') do
        expect(find(:test_id, 'rank').text).to eq('1')
        expect(find(:test_id, 'team').text).to eq(@team2.name).or eq(@team1.name)
        expect(find(:test_id, 'win-points').text).to eq('4')
        expect(find(:test_id, 'wins').text).to eq('1')
        expect(find(:test_id, 'draws').text).to eq('1')
        expect(find(:test_id, 'loses').text).to eq('0')
        expect(find(:test_id, 'total_goals').text).to eq('2')
        expect(find(:test_id, 'total_against_goals').text).to eq('0')
        expect(find(:test_id, 'goal_diff').text).to eq('2')
      end
      within find(:test_id, 'rank3') do
        expect(find(:test_id, 'rank').text).to eq('3')
        expect(find(:test_id, 'team').text).to eq(@team3.name)
        expect(find(:test_id, 'win-points').text).to eq('0')
        expect(find(:test_id, 'wins').text).to eq('0')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('2')
        expect(find(:test_id, 'total_goals').text).to eq('0')
        expect(find(:test_id, 'total_against_goals').text).to eq('3')
        expect(find(:test_id, 'goal_diff').text).to eq('-3')
      end

    end

    example "1:勝点、2:得失点差" do
      visit roundrobin_path(roundrobin)
      expect(page).to have_selector 'h1', text: roundrobin.name

      # 得失点差を順位条件2に追加
      click_on "設定"
      expect(page).to have_button '更新'
      select '得失点差', from: '順位条件2'
      click_on "更新"

      click_on '順位表'

      # 1位と2位が区別される。
      within find(:test_id, 'rank1') do
        expect(find(:test_id, 'rank').text).to eq('1')
        expect(find(:test_id, 'team').text).to eq(@team2.name)
        expect(find(:test_id, 'win-points').text).to eq('4')
        expect(find(:test_id, 'wins').text).to eq('1')
        expect(find(:test_id, 'draws').text).to eq('1')
        expect(find(:test_id, 'loses').text).to eq('0')
        expect(find(:test_id, 'total_goals').text).to eq('2')
        expect(find(:test_id, 'total_against_goals').text).to eq('0')
        expect(find(:test_id, 'goal_diff').text).to eq('2')
      end
      within find(:test_id, 'rank2') do
        expect(find(:test_id, 'rank').text).to eq('2')
        expect(find(:test_id, 'team').text).to eq(@team1.name)
        expect(find(:test_id, 'win-points').text).to eq('4')
        expect(find(:test_id, 'wins').text).to eq('1')
        expect(find(:test_id, 'draws').text).to eq('1')
        expect(find(:test_id, 'loses').text).to eq('0')
        expect(find(:test_id, 'total_goals').text).to eq('1')
        expect(find(:test_id, 'total_against_goals').text).to eq('0')
        expect(find(:test_id, 'goal_diff').text).to eq('1')
      end
      within find(:test_id, 'rank3') do
        expect(find(:test_id, 'rank').text).to eq('3')
        expect(find(:test_id, 'team').text).to eq(@team3.name)
        expect(find(:test_id, 'win-points').text).to eq('0')
        expect(find(:test_id, 'wins').text).to eq('0')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('2')
        expect(find(:test_id, 'total_goals').text).to eq('0')
        expect(find(:test_id, 'total_against_goals').text).to eq('3')
        expect(find(:test_id, 'goal_diff').text).to eq('-3')
      end

    end
  end

  describe "総得点での順位判定" do

    let!(:roundrobin) { create(:roundrobin, :with_teams, num_of_teams: 3, has_score: true, rank1: :win_points, rank2: :goal_diff) }
    before do
      @team1 = roundrobin.teams[0]
      @team2 = roundrobin.teams[1]
      @team3 = roundrobin.teams[2]

      roundrobin.games.create(round: 1, gameNo: nil, a_team: @team1, b_team: @team2, win_team: @team1, lose_team: @team2,
                              a_result: 'DRAW', b_result: 'DRAW', a_score_num: 0, b_score_num: 0)
      roundrobin.games.create(round: 1, gameNo: nil, a_team: @team1, b_team: @team3, win_team: @team1, lose_team: @team3,
                              a_result: 'WIN', b_result: 'LOSE', a_score_num: 4, b_score_num: 0)
      roundrobin.games.create(round: 1, gameNo: nil, a_team: @team2, b_team: @team3, win_team: @team2, lose_team: @team3,
                              a_result: 'WIN', b_result: 'LOSE', a_score_num: 5, b_score_num: 1)
    end

    example "1:勝点、2:得失点差　のみ" do
      visit roundrobin_path(roundrobin)

      expect(page).to have_selector 'h1', text: roundrobin.name
      click_on '順位表'

      expect(page).to have_content "順位条件"
      expect(page).to have_content "勝点"

      # 1位が2チーム
      within find(:test_id, 'rank1') do
        expect(find(:test_id, 'rank').text).to eq('1')
        expect(find(:test_id, 'team').text).to eq(@team1.name)
        expect(find(:test_id, 'win-points').text).to eq('4')
        expect(find(:test_id, 'wins').text).to eq('1')
        expect(find(:test_id, 'draws').text).to eq('1')
        expect(find(:test_id, 'loses').text).to eq('0')
        expect(find(:test_id, 'total_goals').text).to eq('4')
        expect(find(:test_id, 'total_against_goals').text).to eq('0')
        expect(find(:test_id, 'goal_diff').text).to eq('4')
      end
      within find(:test_id, 'rank2') do
        expect(find(:test_id, 'rank').text).to eq('1')
        expect(find(:test_id, 'team').text).to eq(@team2.name)
        expect(find(:test_id, 'win-points').text).to eq('4')
        expect(find(:test_id, 'wins').text).to eq('1')
        expect(find(:test_id, 'draws').text).to eq('1')
        expect(find(:test_id, 'loses').text).to eq('0')
        expect(find(:test_id, 'total_goals').text).to eq('5')
        expect(find(:test_id, 'total_against_goals').text).to eq('1')
        expect(find(:test_id, 'goal_diff').text).to eq('4')
      end
      within find(:test_id, 'rank3') do
        expect(find(:test_id, 'rank').text).to eq('3')
        expect(find(:test_id, 'team').text).to eq(@team3.name)
        expect(find(:test_id, 'win-points').text).to eq('0')
        expect(find(:test_id, 'wins').text).to eq('0')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('2')
        expect(find(:test_id, 'total_goals').text).to eq('1')
        expect(find(:test_id, 'total_against_goals').text).to eq('9')
        expect(find(:test_id, 'goal_diff').text).to eq('-8')
      end

    end

    example "1:勝点、2:得失点差、3:総得点" do
      visit roundrobin_path(roundrobin)
      expect(page).to have_selector 'h1', text: roundrobin.name

      # 総得点を順位条件3に追加
      click_on "設定"
      expect(page).to have_button '更新'
      select '総得点', from: '順位条件3'
      click_on "更新"

      click_on '順位表'

      # 1位と2位が区別される。
      within find(:test_id, 'rank1') do
        expect(find(:test_id, 'rank').text).to eq('1')
        expect(find(:test_id, 'team').text).to eq(@team2.name)
        expect(find(:test_id, 'win-points').text).to eq('4')
        expect(find(:test_id, 'wins').text).to eq('1')
        expect(find(:test_id, 'draws').text).to eq('1')
        expect(find(:test_id, 'loses').text).to eq('0')
        expect(find(:test_id, 'total_goals').text).to eq('5')
        expect(find(:test_id, 'total_against_goals').text).to eq('1')
        expect(find(:test_id, 'goal_diff').text).to eq('4')
      end
      within find(:test_id, 'rank2') do
        expect(find(:test_id, 'rank').text).to eq('2')
        expect(find(:test_id, 'team').text).to eq(@team1.name)
        expect(find(:test_id, 'win-points').text).to eq('4')
        expect(find(:test_id, 'wins').text).to eq('1')
        expect(find(:test_id, 'draws').text).to eq('1')
        expect(find(:test_id, 'loses').text).to eq('0')
        expect(find(:test_id, 'total_goals').text).to eq('4')
        expect(find(:test_id, 'total_against_goals').text).to eq('0')
        expect(find(:test_id, 'goal_diff').text).to eq('4')
      end
      within find(:test_id, 'rank3') do
        expect(find(:test_id, 'rank').text).to eq('3')
        expect(find(:test_id, 'team').text).to eq(@team3.name)
        expect(find(:test_id, 'win-points').text).to eq('0')
        expect(find(:test_id, 'wins').text).to eq('0')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('2')
        expect(find(:test_id, 'total_goals').text).to eq('1')
        expect(find(:test_id, 'total_against_goals').text).to eq('9')
        expect(find(:test_id, 'goal_diff').text).to eq('-8')
      end

    end
  end

  describe "直接対決での順位判定" do

    let!(:roundrobin) { create(:roundrobin, :with_teams, num_of_teams: 4, has_score: false, rank1: :win_points) }
    before do
      @team1 = roundrobin.teams[0]
      @team2 = roundrobin.teams[1]
      @team3 = roundrobin.teams[2]
      @team4 = roundrobin.teams[3]

      roundrobin.games.create(round: 1, gameNo: nil, a_team: @team1, b_team: @team2, win_team: @team1, lose_team: @team2, a_result: 'WIN', b_result: 'LOSE')
      roundrobin.games.create(round: 1, gameNo: nil, a_team: @team1, b_team: @team3, win_team: @team1, lose_team: @team3, a_result: 'WIN', b_result: 'LOSE')
      roundrobin.games.create(round: 1, gameNo: nil, a_team: @team1, b_team: @team4, win_team: @team1, lose_team: @team4, a_result: 'LOSE', b_result: 'WIN')
      roundrobin.games.create(round: 1, gameNo: nil, a_team: @team2, b_team: @team3, win_team: @team2, lose_team: @team3, a_result: 'WIN', b_result: 'LOSE')
      roundrobin.games.create(round: 1, gameNo: nil, a_team: @team2, b_team: @team4, win_team: @team2, lose_team: @team4, a_result: 'LOSE', b_result: 'WIN')
      roundrobin.games.create(round: 1, gameNo: nil, a_team: @team3, b_team: @team4, win_team: @team3, lose_team: @team4, a_result: 'WIN', b_result: 'LOSE')
    end

    example "1:勝点　のみ" do
      visit roundrobin_path(roundrobin)

      expect(page).to have_selector 'h1', text: roundrobin.name
      click_on '順位表'

      expect(page).to have_content "順位条件"
      expect(page).to have_content "勝点"

      # 1位が2チーム、3位が2チーム
      within find(:test_id, 'rank1') do
        expect(find(:test_id, 'rank').text).to eq('1')
        # expect(find(:test_id, 'team').text).to eq(@team1.name)
        expect(find(:test_id, 'win-points').text).to eq('6')
        expect(find(:test_id, 'wins').text).to eq('2')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('1')
      end
      within find(:test_id, 'rank2') do
        expect(find(:test_id, 'rank').text).to eq('1')
        # expect(find(:test_id, 'team').text).to eq(@team4.name)
        expect(find(:test_id, 'win-points').text).to eq('6')
        expect(find(:test_id, 'wins').text).to eq('2')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('1')
      end
      within find(:test_id, 'rank3') do
        expect(find(:test_id, 'rank').text).to eq('3')
        # expect(find(:test_id, 'team').text).to eq(@team2.name)
        expect(find(:test_id, 'win-points').text).to eq('3')
        expect(find(:test_id, 'wins').text).to eq('1')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('2')
      end
      within find(:test_id, 'rank4') do
        expect(find(:test_id, 'rank').text).to eq('3')
        # expect(find(:test_id, 'team').text).to eq(@team3.name)
        expect(find(:test_id, 'win-points').text).to eq('3')
        expect(find(:test_id, 'wins').text).to eq('1')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('2')
      end
    end

    example "1:勝点、2:直接対決" do
      visit roundrobin_path(roundrobin)
      expect(page).to have_selector 'h1', text: roundrobin.name

      # 総得点を順位条件3に追加
      click_on "設定"
      expect(page).to have_button '更新'
      select '直接対決', from: '順位条件3'
      click_on "更新"

      click_on '順位表'

      # 1位と2位、3位と4位が区別される。
      within find(:test_id, 'rank1') do
        expect(find(:test_id, 'rank').text).to eq('1')
        expect(find(:test_id, 'team').text).to eq(@team4.name)
        expect(find(:test_id, 'win-points').text).to eq('6')
        expect(find(:test_id, 'wins').text).to eq('2')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('1')
      end
      within find(:test_id, 'rank2') do
        expect(find(:test_id, 'rank').text).to eq('2')
        expect(find(:test_id, 'team').text).to eq(@team1.name)
        expect(find(:test_id, 'win-points').text).to eq('6')
        expect(find(:test_id, 'wins').text).to eq('2')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('1')
      end
      within find(:test_id, 'rank3') do
        expect(find(:test_id, 'rank').text).to eq('3')
        expect(find(:test_id, 'team').text).to eq(@team2.name)
        expect(find(:test_id, 'win-points').text).to eq('3')
        expect(find(:test_id, 'wins').text).to eq('1')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('2')
      end
      within find(:test_id, 'rank4') do
        expect(find(:test_id, 'rank').text).to eq('4')
        expect(find(:test_id, 'team').text).to eq(@team3.name)
        expect(find(:test_id, 'win-points').text).to eq('3')
        expect(find(:test_id, 'wins').text).to eq('1')
        expect(find(:test_id, 'draws').text).to eq('0')
        expect(find(:test_id, 'loses').text).to eq('2')
      end

    end
  end

end
