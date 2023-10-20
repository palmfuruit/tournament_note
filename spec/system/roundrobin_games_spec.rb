require 'rails_helper'

RSpec.describe "リーグ戦試合", type: :system do

  describe "試合結果更新" do
    context "スコアなし" do
      let!(:roundrobin) { create(:roundrobin, :with_teams, num_of_teams: 4) }

      example do
        teams = roundrobin.teams.order(:entryNo)
        team1 = teams[0]
        team2 = teams[1]

        # 試合結果の登録
        visit roundrobin_path(roundrobin)

        expect(page).to have_selector 'h1', text: roundrobin.name
        find('#game-1-2 a').click

        expect(page).to have_field team1.name
        expect(page).to have_field team2.name
        expect(page).not_to have_content "リセット"
        click_on "更新"

        expect(page).to have_content "勝利チームを選択してください"
        choose(team1.name)
        click_on "更新"

        expect(page).not_to have_field team1.name
        expect(page).not_to have_field team2.name
        expect(find('#game-1-2')).to have_mark('win')
        expect(find('#game-2-1')).to have_mark('lose')

        # 試合結果の更新
        find('#game-2-1 a').click
        expect(page).to have_field team2.name
        expect(page).to have_field team1.name
        expect(page).to have_content "リセット"
        expect(page).to have_checked_field(team1.name)

        choose('引き分け')
        click_on "更新"

        expect(page).not_to have_field team2.name
        expect(page).not_to have_field team1.name
        expect(find('#game-1-2')).to have_mark('draw')
        expect(find('#game-2-1')).to have_mark('draw')

        # 試合結果のリセット
        find('#game-2-1 a').click
        expect(page).to have_field team2.name
        expect(page).to have_field team1.name
        expect(page).to have_content "リセット"
        expect(page).to have_checked_field('引き分け')

        page.accept_confirm do
          click_on 'リセット'
        end
        expect(page).not_to have_field team2.name
        expect(page).not_to have_field team1.name
        expect(find('#game-1-2')).not_to have_mark('')
        expect(find('#game-2-1')).not_to have_mark('')
      end
    end

    context "スコアあり" do
      let!(:roundrobin) { create(:roundrobin, :with_teams, num_of_teams: 4, has_score: true) }

      example do
        teams = roundrobin.teams.order(:entryNo)
        team1 = teams[0]
        team2 = teams[1]

        # 試合結果の登録
        visit roundrobin_path(roundrobin)

        expect(page).to have_selector 'h1', text: roundrobin.name
        find('#game-1-2 a').click

        fill_in 'game_a_score_num', with: '3'
        fill_in 'game_b_score_num', with: '2'
        choose(team1.name)
        click_on "更新"

        expect(page).not_to have_field team1.name
        expect(page).not_to have_field team2.name
        expect(find('#game-1-2')).to have_mark('win')
        expect(find('#game-1-2')).to have_content('3 - 2')
        expect(find('#game-2-1')).to have_mark('lose')
        expect(find('#game-2-1')).to have_content('2 - 3')
      end
    end
  end

  describe "複数Round 試合結果更新" do
    let!(:roundrobin) { create(:roundrobin, :with_teams, num_of_teams: 4, num_of_round: 2) }

    context 'Round1 1試合実施' do
      before do
        teams = roundrobin.teams.order(:entryNo)
        @team1 = teams[0]
        @team2 = teams[1]
        @team3 = teams[2]
        @team4 = teams[3]

        roundrobin.games.create(round: 1, gameNo: nil, a_team: @team1, b_team: @team2, win_team: @team1, lose_team: @team2, a_result: 'WIN', b_result: 'LOSE')
        roundrobin.games.create(round: 2, gameNo: nil, a_team: @team1, b_team: @team2, win_team: @team2, lose_team: @team1, a_result: 'LOSE', b_result: 'WIN')
      end

      it 'Round2の試合更新後、Round2表示が維持される。' do
        visit roundrobin_path(roundrobin)

        expect(page).to have_selector 'h1', text: roundrobin.name

        # Round 1の試合結果が表示される。
        expect(page).to have_content "Round 1 / 2"
        expect(page).to have_select('round', selected: 'Round 1　(1試合)')
        expect(find('#game-1-2')).to have_mark('win')
        expect(find('#game-2-1')).to have_mark('lose')

        # Round 2に遷移
        select 'Round 2', from: 'round'
        expect(page).to have_content "Round 2 / 2"
        expect(page).to have_select('round', selected: 'Round 2　(1試合)')
        expect(find('#game-1-2')).to have_mark('lose')
        expect(find('#game-2-1')).to have_mark('win')

        # 試合結果の更新
        find('#game-3-4 a').click
        expect(page).to have_field @team3.name
        expect(page).to have_field @team4.name
        choose(@team3.name)
        click_on "更新"

        # Round 2の試合結果が表示される。
        expect(page).to have_content "Round 2 / 2"
        expect(page).to have_select('round', selected: 'Round 2　(2試合)')
        expect(find('#game-1-2')).to have_mark('lose')
        expect(find('#game-2-1')).to have_mark('win')
        expect(find('#game-3-4')).to have_mark('win')
        expect(find('#game-4-3')).to have_mark('lose')

        # 試合結果のリセット
        find('#game-3-4 a').click
        expect(page).to have_field @team3.name
        expect(page).to have_field @team4.name
        expect(page).to have_content "リセット"
        expect(page).to have_checked_field(@team3.name)

        page.accept_confirm do
          click_on 'リセット'
        end
        expect(page).not_to have_field @team3.name
        expect(page).not_to have_field @team4.name

        expect(page).to have_content "Round 2 / 2"
        expect(page).to have_select('round', selected: 'Round 2　(1試合)')
        expect(find('#game-1-2')).to have_mark('lose')
        expect(find('#game-2-1')).to have_mark('win')
        expect(find('#game-3-4')).not_to have_mark('')
        expect(find('#game-4-3')).not_to have_mark('')
      end

    end
  end
end
