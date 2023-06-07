require 'rails_helper'

RSpec.describe "トーナメントの参加チーム", type: :system do

  context "チーム登録済" do
    let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 4) }
    before do
      visit elimination_teams_path(elimination)
    end

    example '名前変更' do
      team1 = elimination.teams[0]

      expect(page).to have_content "4チーム"
      expect(page).to have_content "[1]　#{team1.name}"

      # 名前変更
      click_on "変更", match: :first
      fill_in "チーム名", with: "NewName"
      find(:test_id, 'ok').click
      expect(page).to have_content "[1]　NewName"
    end

    example '追加' do
      click_on "追加"
      fill_in "チーム名", with: "新しいチーム"
      find(:test_id, 'ok').click
      expect(page).to have_content "5チーム"
      expect(page).to have_content "[5]　新しいチーム"
    end

    example '削除' do
      team2 = elimination.teams[1]

      page.accept_confirm do
        click_on '削除', match: :first
      end
      expect(page).to have_content "3チーム"
      expect(page).to have_content "[1]　#{team2.name}"
      expect(page).to have_content "変更", count: 3
    end

    it '変更キャンセル' do
      team1 = elimination.teams[0]

      click_on "変更", match: :first
      expect(page).to have_content "変更", count: 3
      fill_in "チーム名", with: "NewName"
      find(:test_id, 'cancel').click

      expect(page).to_not have_content "[1]　NewName"
      expect(page).to have_content "[1]　#{team1.name}"
    end

    xit 'ユニフォーム設定'
    xit '複数の変更ボタンをクリック時'
    xit 'エラー発生時に画面がへんなとこにとばない'
  end

  describe "0件表示" do
    let!(:elimination) { create(:elimination) }
    example do
      visit elimination_teams_path(elimination)
      expect(page).to have_content "0チーム"
      expect(page).to have_content "参加チームは未登録です"
    end
  end

  context "Team数が上限" do
    let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 16) }
    it '追加ボタンが表示されない' do
      visit elimination_teams_path(elimination)
      expect(page).to_not have_link "追加"
    end
  end

  context "トーナメント進行中" do
    let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 4) }
    before do
      team1 = elimination.teams[0]
      team2 = elimination.teams[1]
      elimination.games.create(round: 1, gameNo: 1, a_team: team1, b_team: team2, win_team: team1, lose_team: team2, a_result: 'WIN', b_result: 'LOSE')
    end
    it '追加、削除ボタンが表示されない' do
      visit elimination_teams_path(elimination)
      expect(page).to_not have_link "追加"
      expect(page).to_not have_link "削除"
    end
  end


end
