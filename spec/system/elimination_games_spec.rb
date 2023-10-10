require 'rails_helper'

RSpec.describe "トーナメント試合", type: :system do

  describe "試合結果更新" do
    let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 4) }

    example do
      team1 = elimination.teams[0]
      team2 = elimination.teams[1]

      # 試合結果の登録
      visit elimination_path(elimination)

      expect(page).to have_selector 'h1', text: elimination.name
      click_on "1-1-game"

      expect(page).to have_field team1.name
      expect(page).to have_field team2.name
      expect(page).not_to have_content "リセット"
      click_on "更新"

      expect(page).to have_content "勝利チームを選択してください"
      choose(team1.name)
      click_on "更新"

      expect(page).not_to have_field team1.name
      expect(page).not_to have_field team2.name
      expect(page).to have_css('.r-top')

      # 試合結果の更新
      click_on "1-1-game"
      expect(page).to have_field team1.name
      expect(page).to have_field team2.name
      expect(page).to have_content "リセット"
      choose(team2.name)
      click_on "更新"
      expect(page).to have_css('.r-bottom')

      # 試合結果のリセット
      click_on "1-1-game"
      expect(page).to have_field team1.name
      expect(page).to have_field team2.name
      expect(page).to have_content "リセット"
      page.accept_confirm do
        click_on 'リセット'
      end
      expect(page).not_to have_css('.r-top')
      expect(page).not_to have_css('.r-bottom')
    end
  end

end
