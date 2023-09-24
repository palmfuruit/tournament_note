require 'rails_helper'

RSpec.describe "リーグ順位表", type: :system do

  let!(:roundrobin) { create(:roundrobin, :with_teams, num_of_teams: 4, rank1: :win_points) }

  before do
    @team1 = roundrobin.teams[0]
    @team2 = roundrobin.teams[1]
    @team3 = roundrobin.teams[2]
    @team4 = roundrobin.teams[3]

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
      expect(find(:test_id, 'wins').text).to eq('2')
      expect(find(:test_id, 'draws').text).to eq('0')
      expect(find(:test_id, 'loses').text).to eq('1')
      expect(find(:test_id, 'win-points').text).to eq('6')
      expect(find(:test_id, 'win-rate').text).to eq('66%')
    end
    within find(:test_id, 'rank2') do
      expect(find(:test_id, 'rank').text).to eq('2')
      expect(find(:test_id, 'team').text).to eq(@team4.name)
      expect(find(:test_id, 'wins').text).to eq('1')
      expect(find(:test_id, 'draws').text).to eq('0')
      expect(find(:test_id, 'loses').text).to eq('0')
      expect(find(:test_id, 'win-points').text).to eq('3')
      expect(find(:test_id, 'win-rate').text).to eq('100%')
    end
    within find(:test_id, 'rank3') do
      expect(find(:test_id, 'rank').text).to eq('3')
      expect(find(:test_id, 'team').text).to eq(@team2.name)
      expect(find(:test_id, 'wins').text).to eq('0')
      expect(find(:test_id, 'draws').text).to eq('0')
      expect(find(:test_id, 'loses').text).to eq('1')
      expect(find(:test_id, 'win-points').text).to eq('0')
      expect(find(:test_id, 'win-rate').text).to eq('0%')
    end
    within find(:test_id, 'rank4') do
      expect(find(:test_id, 'rank').text).to eq('3')
      expect(find(:test_id, 'team').text).to eq(@team3.name)
      expect(find(:test_id, 'wins').text).to eq('0')
      expect(find(:test_id, 'draws').text).to eq('0')
      expect(find(:test_id, 'loses').text).to eq('1')
      expect(find(:test_id, 'win-points').text).to eq('0')
      expect(find(:test_id, 'win-rate').text).to eq('0%')
    end
  end

  it "順位表が正しく表示される(1:勝率)" do
    visit roundrobin_path(roundrobin)

    expect(page).to have_selector 'h1', text: roundrobin.name

    # 順位条件を「勝率」に変更
    click_on "設定"
    expect(page).to have_button '更新'
    select '勝率', from: '順位決め 優先1'
    click_on "更新"

    click_on '順位表'

    expect(page).to have_content "順位条件"
    expect(page).to have_content "勝率"

    within find(:test_id, 'rank1') do
      expect(find(:test_id, 'rank').text).to eq('1')
      expect(find(:test_id, 'team').text).to eq(@team4.name)
      expect(find(:test_id, 'wins').text).to eq('1')
      expect(find(:test_id, 'draws').text).to eq('0')
      expect(find(:test_id, 'loses').text).to eq('0')
      expect(find(:test_id, 'win-points').text).to eq('3')
      expect(find(:test_id, 'win-rate').text).to eq('100%')
    end
    within find(:test_id, 'rank2') do
      expect(find(:test_id, 'rank').text).to eq('2')
      expect(find(:test_id, 'team').text).to eq(@team1.name)
      expect(find(:test_id, 'wins').text).to eq('2')
      expect(find(:test_id, 'draws').text).to eq('0')
      expect(find(:test_id, 'loses').text).to eq('1')
      expect(find(:test_id, 'win-points').text).to eq('6')
      expect(find(:test_id, 'win-rate').text).to eq('66%')
    end
    within find(:test_id, 'rank3') do
      expect(find(:test_id, 'rank').text).to eq('3')
      expect(find(:test_id, 'team').text).to eq(@team2.name)
      expect(find(:test_id, 'wins').text).to eq('0')
      expect(find(:test_id, 'draws').text).to eq('0')
      expect(find(:test_id, 'loses').text).to eq('1')
      expect(find(:test_id, 'win-points').text).to eq('0')
      expect(find(:test_id, 'win-rate').text).to eq('0%')
    end
    within find(:test_id, 'rank4') do
      expect(find(:test_id, 'rank').text).to eq('3')
      expect(find(:test_id, 'team').text).to eq(@team3.name)
      expect(find(:test_id, 'wins').text).to eq('0')
      expect(find(:test_id, 'draws').text).to eq('0')
      expect(find(:test_id, 'loses').text).to eq('1')
      expect(find(:test_id, 'win-points').text).to eq('0')
      expect(find(:test_id, 'win-rate').text).to eq('0%')
    end
  end

end
