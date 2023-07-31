require 'rails_helper'

RSpec.describe "リーグ", type: :system do

  describe "リーグ作成" do
    example do
      visit root_path

      click_on "リーグ表作成"
      expect(page).to have_selector 'h1', text: "新しいリーグ"

      fill_in 'リーグ名', with: "予選リーグ "
      select '6', from: '参加チーム数'
      click_on "登録"

      expect(page).to have_selector 'h1', text: "予選リーグ"
      click_on "チーム"
      expect(page).to have_content "6チーム"
    end
  end

  describe "リーグ作成失敗" do
    example do
      visit root_path

      click_on "リーグ表作成"
      expect(page).to have_selector 'h1', text: "新しいリーグ"

      fill_in 'リーグ名', with: ""
      # click_on "登録"
      expect { click_on "登録" }.to change { Tournament.count }.by(0)
      expect(page).to have_content "リーグ名を入力してください"
    end
  end

  describe "リーグ名変更" do
    let!(:roundrobin) { create(:roundrobin, :with_teams, num_of_teams: 4) }
    example do
      visit roundrobin_path(roundrobin)

      expect(page).to have_selector 'h1', text: roundrobin.name
      click_on "設定"

      expect(page).to have_field 'リーグ名'
      fill_in 'リーグ名', with: "予選リーグ"
      click_on "更新"

      expect(page).to have_selector 'h1', text: "予選リーグ"
    end
  end

  describe "リーグリセット" do
    let!(:roundrobin) { create(:roundrobin, :with_teams, num_of_teams: 4) }
    before do
      team1 = roundrobin.teams[0]
      team2 = roundrobin.teams[1]
      team3 = roundrobin.teams[2]
      team4 = roundrobin.teams[3]

      roundrobin.games.create(round: 1, gameNo: nil, a_team: team1, b_team: team2, win_team: team1, lose_team: team2, a_result: 'WIN', b_result: 'LOSE')
      roundrobin.games.create(round: 1, gameNo: nil, a_team: team3, b_team: team4, win_team: team4, lose_team: team3, a_result: 'LOSE', b_result: 'WIN')
    end
    example do
      visit roundrobin_path(roundrobin)

      expect(page).to have_selector 'h1', text: roundrobin.name
      expect(find('#game-1-2')).to have_mark('win')
      expect(find('#game-2-1')).to have_mark('lose')
      expect(find('#game-3-4')).to have_mark('lose')
      expect(find('#game-4-3')).to have_mark('win')
      click_on "設定"

      expect(page).to have_field 'リーグ名'
      click_on 'リセット'
      page.accept_confirm
      expect(page).to have_content "リーグをリセットしました"

      expect(find('#game-1-2')).not_to have_mark('')
    end
  end

  describe "リーグ削除" do
    let!(:roundrobin) { create(:roundrobin) }
    example do
      visit roundrobin_path(roundrobin)

      expect(page).to have_selector 'h1', text: roundrobin.name
      click_on "設定"

      expect(page).to have_field 'リーグ名'
      click_on '削除'
      page.accept_confirm
      expect(page).to have_content "リーグを削除しました"
    end
  end

  describe "チーム数不足" do
    let!(:roundrobin) { create(:roundrobin, :with_teams, num_of_teams: 1) }
    example do
      visit roundrobin_path(roundrobin)

      expect(page).to have_selector 'h1', text: roundrobin.name
      expect(page).to have_content "参加チームが2チーム以上必要です"
    end
  end

  describe "リーグステータス" do
    let!(:roundrobin) { create(:roundrobin, :with_teams, num_of_teams: 4, num_of_round: 2) }

    context '試合未実施' do
      it 'ステータス [開始前]' do
        visit roundrobin_path(roundrobin)
        expect(find(:test_id, 'tournament-status')).to have_content "開始前"
      end
    end

    context '第一試合実施' do
      before do
        team1 = roundrobin.teams[0]
        team2 = roundrobin.teams[1]
        roundrobin.games.create(round: 1, gameNo: nil, a_team: team1, b_team: team2, win_team: team1, lose_team: team2, a_result: 'WIN', b_result: 'LOSE')
      end

      it 'ステータス [進行中]' do
        visit roundrobin_path(roundrobin)
        expect(find(:test_id, 'tournament-status')).to have_content "進行中"
      end
    end

    context '1Round全試合実施' do
      before do
        team1 = roundrobin.teams[0]
        team2 = roundrobin.teams[1]
        team3 = roundrobin.teams[2]
        team4 = roundrobin.teams[3]

        roundrobin.games.create(round: 1, gameNo: nil, a_team: team1, b_team: team2, win_team: team1, lose_team: team2, a_result: 'WIN', b_result: 'LOSE')
        roundrobin.games.create(round: 1, gameNo: nil, a_team: team1, b_team: team3, win_team: team1, lose_team: team3, a_result: 'WIN', b_result: 'LOSE')
        roundrobin.games.create(round: 1, gameNo: nil, a_team: team1, b_team: team4, win_team: team1, lose_team: team4, a_result: 'WIN', b_result: 'LOSE')
        roundrobin.games.create(round: 1, gameNo: nil, a_team: team2, b_team: team3, win_team: team2, lose_team: team3, a_result: 'WIN', b_result: 'LOSE')
        roundrobin.games.create(round: 1, gameNo: nil, a_team: team2, b_team: team4, win_team: team2, lose_team: team4, a_result: 'WIN', b_result: 'LOSE')
        roundrobin.games.create(round: 1, gameNo: nil, a_team: team3, b_team: team4, win_team: team3, lose_team: team4, a_result: 'WIN', b_result: 'LOSE')
      end

      it 'ステータス [進行中]' do
        visit roundrobin_path(roundrobin)
        expect(find(:test_id, 'tournament-status')).to have_content "進行中"
      end
    end

    context '全Round全試合実施' do
      before do
        team1 = roundrobin.teams[0]
        team2 = roundrobin.teams[1]
        team3 = roundrobin.teams[2]
        team4 = roundrobin.teams[3]

        roundrobin.games.create(round: 1, gameNo: nil, a_team: team1, b_team: team2, win_team: team1, lose_team: team2, a_result: 'WIN', b_result: 'LOSE')
        roundrobin.games.create(round: 1, gameNo: nil, a_team: team1, b_team: team3, win_team: team1, lose_team: team3, a_result: 'WIN', b_result: 'LOSE')
        roundrobin.games.create(round: 1, gameNo: nil, a_team: team1, b_team: team4, win_team: team1, lose_team: team4, a_result: 'WIN', b_result: 'LOSE')
        roundrobin.games.create(round: 1, gameNo: nil, a_team: team2, b_team: team3, win_team: team2, lose_team: team3, a_result: 'WIN', b_result: 'LOSE')
        roundrobin.games.create(round: 1, gameNo: nil, a_team: team2, b_team: team4, win_team: team2, lose_team: team4, a_result: 'WIN', b_result: 'LOSE')
        roundrobin.games.create(round: 1, gameNo: nil, a_team: team3, b_team: team4, win_team: team3, lose_team: team4, a_result: 'WIN', b_result: 'LOSE')
        roundrobin.games.create(round: 2, gameNo: nil, a_team: team1, b_team: team2, win_team: team1, lose_team: team2, a_result: 'WIN', b_result: 'LOSE')
        roundrobin.games.create(round: 2, gameNo: nil, a_team: team1, b_team: team3, win_team: team1, lose_team: team3, a_result: 'WIN', b_result: 'LOSE')
        roundrobin.games.create(round: 2, gameNo: nil, a_team: team1, b_team: team4, win_team: team1, lose_team: team4, a_result: 'WIN', b_result: 'LOSE')
        roundrobin.games.create(round: 2, gameNo: nil, a_team: team2, b_team: team3, win_team: team2, lose_team: team3, a_result: 'WIN', b_result: 'LOSE')
        roundrobin.games.create(round: 2, gameNo: nil, a_team: team2, b_team: team4, win_team: team2, lose_team: team4, a_result: 'WIN', b_result: 'LOSE')
        roundrobin.games.create(round: 2, gameNo: nil, a_team: team3, b_team: team4, win_team: team3, lose_team: team4, a_result: 'WIN', b_result: 'LOSE')
      end

      it 'ステータス [終了]' do
        visit roundrobin_path(roundrobin)
        expect(find(:test_id, 'tournament-status')).to have_content "終了"
      end
    end

  end

end
