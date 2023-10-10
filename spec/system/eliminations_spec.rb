require 'rails_helper'

RSpec.describe "トーナメント", type: :system do

  describe "トーナメント作成" do
    example do
      visit root_path

      click_on "トーナメント表作成"
      expect(page).to have_selector 'h1', text: "トーナメント表作成"

      fill_in '大会名', with: "甲子園"
      select '6', from: '参加チーム数'
      click_on "作成"

      expect(page).to have_selector 'h1', text: "甲子園"
      click_on "チーム"
      expect(page).to have_content "6チーム"
    end
  end

  describe "大会名デフォルト値で生成" do
    example do
      visit root_path

      click_on "トーナメント表作成"
      expect(page).to have_selector 'h1', text: "トーナメント表作成"

      fill_in '大会名', with: ""
      click_on "作成"
      expect(page).to have_selector 'h1', text: "#{Date.today}"
    end
  end

  describe "大会名変更" do
    let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 4) }
    example do
      visit elimination_path(elimination)

      expect(page).to have_selector 'h1', text: elimination.name
      click_on "設定"

      expect(page).to have_field '大会名'
      fill_in '大会名', with: "甲子園"
      click_on "更新"

      expect(page).to have_selector 'h1', text: "甲子園"
    end
  end

  describe "トーナメントリセット" do
    let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 4) }
    before do
      team1 = elimination.teams[0]
      team2 = elimination.teams[1]
      team3 = elimination.teams[2]
      team4 = elimination.teams[3]

      elimination.games.create(round: 1, gameNo: 1, a_team: team1, b_team: team2, win_team: team1, lose_team: team2, a_result: 'WIN', b_result: 'LOSE')
      elimination.games.create(round: 1, gameNo: 2, a_team: team3, b_team: team4, win_team: team4, lose_team: team3, a_result: 'LOSE', b_result: 'WIN')
    end
    example do
      visit elimination_path(elimination)

      expect(page).to have_selector 'h1', text: elimination.name
      expect(page).to have_css('.r-top')
      expect(page).to have_css('.r-bottom')
      click_on "設定"

      expect(page).to have_field '大会名'
      click_on 'リセット'
      page.accept_confirm
      expect(page).to have_content "トーナメントをリセットしました"

      expect(page).not_to have_css('.r-top')
      expect(page).not_to have_css('.r-bottom')
    end
  end

  describe "トーナメント削除" do
    let!(:elimination) { create(:elimination) }
    example do
      visit elimination_path(elimination)

      expect(page).to have_selector 'h1', text: elimination.name
      click_on "設定"

      expect(page).to have_field '大会名'
      click_on '削除'
      page.accept_confirm
      expect(page).to have_content "トーナメントを削除しました"
    end
  end

  describe "チーム数不足" do
    let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 1) }
    example do
      visit elimination_path(elimination)

      expect(page).to have_selector 'h1', text: elimination.name
      expect(page).to have_content "参加チームが2チーム以上必要です"
    end
  end

  describe "トーナメントステータス" do
    let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 4) }

    context '試合未実施' do
      it 'ステータス [開始前]' do
        visit elimination_path(elimination)
        expect(find(:test_id, 'tournament-status')).to have_content "開始前"
      end
    end

    context '第一試合実施' do
      before do
        team1 = elimination.teams[0]
        team2 = elimination.teams[1]
        elimination.games.create(round: 1, gameNo: 1, a_team: team1, b_team: team2, win_team: team1, lose_team: team2, a_result: 'WIN', b_result: 'LOSE')
      end

      it 'ステータス [進行中]' do
        visit elimination_path(elimination)
        expect(find(:test_id, 'tournament-status')).to have_content "進行中"
      end
    end

    context '決勝戦実施' do
      before do
        team1 = elimination.teams[0]
        team2 = elimination.teams[1]
        team3 = elimination.teams[2]
        team4 = elimination.teams[3]

        elimination.games.create(round: 1, gameNo: 1, a_team: team1, b_team: team2, win_team: team1, lose_team: team2, a_result: 'WIN', b_result: 'LOSE')
        elimination.games.create(round: 1, gameNo: 2, a_team: team3, b_team: team4, win_team: team3, lose_team: team4, a_result: 'WIN', b_result: 'LOSE')
        elimination.games.create(round: 2, gameNo: 1, a_team: team1, b_team: team3, win_team: team1, lose_team: team3, a_result: 'WIN', b_result: 'LOSE')
      end

      it 'ステータス [終了]' do
        visit elimination_path(elimination)
        expect(find(:test_id, 'tournament-status')).to have_content "終了"
      end
    end

  end

end
