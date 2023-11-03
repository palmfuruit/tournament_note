require 'rails_helper'

RSpec.describe "トーナメントの参加チーム", type: :system do

  context "チーム登録済" do
    let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 4) }
    before do
      teams = elimination.teams.order(:entryNo)
      @team1 = teams[0]
      @team2 = teams[1]
      @team3 = teams[2]
      @team4 = teams[3]

      visit tournament_teams_path(elimination.tournament)
    end

    example '一括更新' do
      expect(page).to have_field 'teams_names', with: "#{@team1.name}\n#{@team2.name}\n#{@team3.name}\n#{@team4.name}"

      fill_in 'teams_names', with: "ルフィ\nゾロ\nナミ\nサンジ\nウソップ\nチョッパー"
      click_on '一括更新'

      expect(page).to have_content "6チーム"
      expect(find('#teams')).to have_content "ルフィ"
      expect(page).to have_field 'teams_names', with: "ルフィ\nゾロ\nナミ\nサンジ\nウソップ\nチョッパー"
    end

    example '一括更新エラー' do
      expect(page).to have_field 'teams_names', with: "#{@team1.name}\n#{@team2.name}\n#{@team3.name}\n#{@team4.name}"

      fill_in 'teams_names', with: "ルフィ\nゾロナミサンジウソップチョッパー"
      click_on '一括更新'

      expect(find('#error_explanation')).to have_content "error"

      # 一括更新前の状態
      visit tournament_teams_path(elimination.tournament)
      expect(page).to have_content "4チーム"
      expect(page).to have_field 'teams_names', with: "#{@team1.name}\n#{@team2.name}\n#{@team3.name}\n#{@team4.name}"
    end


    example '名前変更' do
      expect(page).to have_content "4チーム"
      expect(page).to have_content @team1.name

      # 名前変更
      click_on "変更", match: :first
      fill_in "チーム名", with: "NewName"
      find(:test_id, 'ok').click
      expect(page).to have_content "NewName"
      expect(page).to have_field 'teams_names', with: "NewName\n#{@team2.name}\n#{@team3.name}\n#{@team4.name}"
    end

    example '追加' do
      click_on "追加"
      fill_in "チーム名", with: "新しいチーム"
      find(:test_id, 'ok').click
      expect(page).to have_content "5チーム"
      expect(page).to have_content "新しいチーム"
      expect(page).to have_field 'teams_names', with: "#{@team1.name}\n#{@team2.name}\n#{@team3.name}\n#{@team4.name}\n新しいチーム"
    end

    example '削除' do
      page.accept_confirm do
        click_on '削除', match: :first
      end
      expect(page).to have_content "3チーム"
      expect(page).to_not have_content @team1.name
      expect(page).to have_content "変更", count: 3
      expect(page).to have_field 'teams_names', with: "#{@team2.name}\n#{@team3.name}\n#{@team4.name}"

    end

    it '変更キャンセル' do
      click_on "変更", match: :first
      expect(page).to have_content "変更", count: 3
      fill_in "チーム名", with: "NewName"
      find(:test_id, 'cancel').click

      expect(page).to_not have_content "NewName"
      expect(page).to have_content @team1.name
    end
  end

  describe "0件表示" do
    let!(:elimination) { create(:elimination) }
    example do
      visit tournament_teams_path(elimination.tournament)
      expect(page).to have_content "0チーム"
      expect(page).to have_content "参加チームは未登録です"
    end
  end

  context "Team数が上限" do
    let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 16) }
    it '追加ボタンが表示されない' do
      visit tournament_teams_path(elimination.tournament)
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
      visit tournament_teams_path(elimination.tournament)
      expect(page).to_not have_link "追加"
      expect(page).to_not have_link "削除"
      expect(page).to_not have_field 'teams_names'
    end
  end

  describe "ユニフォーム(トーナメント)" do
    let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 4) }
    before do
      visit tournament_teams_path(elimination.tournament)
    end

    example 'ユニフォーム(黄色)指定すると、Team名の前にユニフォームアイコンが表示される。' do
      team1 = elimination.teams[0]

      expect(page).to have_content "4チーム"
      expect(page).to have_content team1.name
      expect(page).to_not have_uniform_icon('')

      click_on "変更", match: :first
      expect(page).to have_checked_field with: 'none'
      choose "team_color_yellow#{team1.id}"
      find(:test_id, 'ok').click
      expect(page).to have_uniform_icon('yellow')

      click_on "トーナメント表"
      expect(page).to have_uniform_icon('yellow')
    end
  end

  describe "ユニフォーム(リーグ表)" do
    let!(:roundrobin) { create(:roundrobin, :with_teams, num_of_teams: 4) }
    before do
      visit tournament_teams_path(roundrobin.tournament)
    end

    example 'ユニフォーム(黄色)指定すると、Team名の前にユニフォームアイコンが表示される。' do
      team1 = roundrobin.teams[0]

      expect(page).to have_content "4チーム"
      expect(page).to have_content team1.name
      expect(page).to_not have_uniform_icon('')

      click_on "変更", match: :first
      expect(page).to have_checked_field with: 'none'
      choose "team_color_yellow#{team1.id}"
      find(:test_id, 'ok').click
      expect(page).to have_uniform_icon('yellow')

      click_on "リーグ表"
      expect(page).to have_uniform_icon('yellow')

      click_on "順位表"
      expect(page).to have_uniform_icon('yellow')
    end
  end

  describe "シャッフル" do
    context "トーナメント/リーグ開始前" do
      let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 4) }
      before do
        teams = elimination.teams.order(:entryNo)
        @team1 = elimination.teams[0]
        @team2 = elimination.teams[1]
        @team3 = elimination.teams[2]
        @team4 = elimination.teams[3]
      end

      example 'シャッフル後に、各チームが表示されている' do
        visit tournament_teams_path(elimination.tournament)

        expect(page).to have_link "シャッフル"
        page.accept_confirm do
          click_on 'シャッフル'
        end

        expect(page).to have_content "4チーム"
        # 一覧画面
        expect(find('#teams')).to have_content @team1.name, count: 1
        expect(find('#teams')).to have_content @team2.name, count: 1
        expect(find('#teams')).to have_content @team3.name, count: 1
        expect(find('#teams')).to have_content @team4.name, count: 1

        # 一括変更 Text Area
        expect(find('#teams_names_tag')).to have_content @team1.name, count: 1
        expect(find('#teams_names_tag')).to have_content @team2.name, count: 1
        expect(find('#teams_names_tag')).to have_content @team3.name, count: 1
        expect(find('#teams_names_tag')).to have_content @team4.name, count: 1

        new_teams = elimination.teams.order(:entryNo)
        expect(page).to have_field 'teams_names', with: "#{new_teams[0].name}\n#{new_teams[1].name}\n#{new_teams[2].name}\n#{new_teams[3].name}"

      end
    end

    context "トーナメント/リーグ進行中" do
      let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 4) }
      before do
        team1 = elimination.teams[0]
        team2 = elimination.teams[1]
        elimination.games.create(round: 1, gameNo: 1, a_team: team1, b_team: team2, win_team: team1, lose_team: team2, a_result: 'WIN', b_result: 'LOSE')

      end

      example 'シャッフルボタンが表示されない' do
        visit tournament_teams_path(elimination.tournament)
        expect(page).to_not have_link "シャッフル"
      end
    end

    context "Team数が0" do
      let!(:elimination) { create(:elimination) }

      example 'シャッフルボタンが表示されない' do
        visit tournament_teams_path(elimination.tournament)
        expect(page).to_not have_link "シャッフル"
      end
    end

  end
end
