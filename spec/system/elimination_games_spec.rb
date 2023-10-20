require 'rails_helper'

RSpec.describe "トーナメント試合", type: :system do

  describe "試合結果更新" do
    context "スコアなし" do

      let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 4) }

      example do
        teams =elimination.teams.order(:entryNo)
        team1 = teams[0]
        team2 = teams[1]

        # 試合結果の登録
        visit elimination_path(elimination)

        expect(page).to have_selector 'h1', text: elimination.name
        find(:test_id, '1-1-game').click_link ''


        expect(page).to have_field team1.name
        expect(page).to have_field team2.name
        expect(page).not_to have_content "リセット"
        click_on "更新"

        expect(page).to have_content "勝利チームを選択してください"
        choose(team1.name)
        click_on "更新"

        expect(page).not_to have_field team1.name
        expect(page).not_to have_field team2.name
        expect(find(:test_id, '1-1-game')).to match_css('.r-top')
        expect(find(:test_id, '1-1-game')).to_not match_css('.r-bottom')
        expect(find(:test_id, '1-1-a-score')).to match_css('.r-left.r-bottom')
        expect(find(:test_id, '1-1-b-score')).to_not match_css('.r-left.r-top')


        # 試合結果の更新
        find(:test_id, '1-1-game').click_link ''
        expect(page).to have_field team1.name
        expect(page).to have_field team2.name
        expect(page).to have_content "リセット"
        choose(team2.name)
        click_on "更新"

        expect(page).not_to have_field team1.name
        expect(page).not_to have_field team2.name
        expect(find(:test_id, '1-1-game')).to_not match_css('.r-top')
        expect(find(:test_id, '1-1-game')).to match_css('.r-bottom')
        expect(find(:test_id, '1-1-a-score')).to_not match_css('.r-left.r-bottom')
        expect(find(:test_id, '1-1-b-score')).to match_css('.r-left.r-top')


        # 試合結果のリセット
        find(:test_id, '1-1-game').click_link ''
        expect(page).to have_field team1.name
        expect(page).to have_field team2.name
        expect(page).to have_content "リセット"
        page.accept_confirm do
          click_on 'リセット'
        end
        expect(page).not_to have_css('.r-top')
        expect(page).not_to have_css('.r-bottom')
        expect(page).not_to have_css('.r-left')
      end
    end


    context "スコアあり" do

      let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 3, has_score: true) }

      example do
        teams =elimination.teams.order(:entryNo)
        team2 = teams[1]
        team3 = teams[2]

        # 試合結果の登録
        visit elimination_path(elimination)

        expect(page).to have_selector 'h1', text: elimination.name
        find(:test_id, '1-2-game').click_link ''


        expect(page).to have_field team2.name
        expect(page).to have_field team3.name
        expect(page).not_to have_content "リセット"
        fill_in 'game_a_score_str', with: 'あああ'
        fill_in 'game_b_score_str', with: 'いいい'
        choose(team2.name)
        click_on "更新"

        expect(page).not_to have_field team2.name
        expect(page).not_to have_field team3.name
        expect(find(:test_id, '1-2-game')).to match_css('.r-top')
        expect(find(:test_id, '1-2-game')).to_not match_css('.r-bottom')
        expect(find(:test_id, '1-2-a-score')).to match_css('.r-left.r-bottom')
        expect(find(:test_id, '1-2-a-score')).to have_content('あああ')
        expect(find(:test_id, '1-2-b-score')).to_not match_css('.r-left.r-top')
        expect(find(:test_id, '1-2-b-score')).to have_content('いいい')
      end
    end
  end

end
