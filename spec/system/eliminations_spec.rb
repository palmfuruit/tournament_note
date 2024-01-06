require 'rails_helper'

RSpec.describe "トーナメント", type: :system do
  include ApplicationHelper

  describe "トーナメント作成" do
    example "デフォルト設定" do
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

    example  "詳細設定あり" do
      visit root_path

      click_on "トーナメント表作成"
      expect(page).to have_selector 'h1', text: "トーナメント表作成"

      fill_in '大会名', with: "甲子園"
      fill_in '説明', with: "甲子園で会いましょう"

      select '6', from: '参加チーム数'
      check 'スコアを記録'
      click_on "作成"

      expect(page).to have_selector 'h1', text: "甲子園"
      expect(page).to have_content "甲子園で会いましょう"

      click_on "設定"
      expect(page).to have_checked_field('スコアを記録')

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
      fill_in '説明', with: "本気の夏、100回目。"

      click_on "更新"

      expect(page).to have_selector 'h1', text: "甲子園"
      expect(page).to have_content "本気の夏、100回目。"
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


  describe "トーナメント結果表示" do
    context '5チーム、上側チーム勝利' do
      let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 5, has_score: true) }

      before do
        team1 = elimination.teams[0]
        team2 = elimination.teams[1]
        team3 = elimination.teams[2]
        team4 = elimination.teams[3]
        team5 = elimination.teams[4]

        elimination.games.create(round: 1, gameNo: 2, a_team: team2, b_team: team3, win_team: team2, lose_team: team3, a_result: 'WIN', b_result: 'LOSE', a_score_str: '1-2A', b_score_str: '1-2B')
        elimination.games.create(round: 2, gameNo: 1, a_team: team1, b_team: team2, win_team: team1, lose_team: team2, a_result: 'WIN', b_result: 'LOSE', a_score_str: '2-1A', b_score_str: '2-1B')
        elimination.games.create(round: 2, gameNo: 2, a_team: team4, b_team: team5, win_team: team4, lose_team: team5, a_result: 'WIN', b_result: 'LOSE', a_score_str: '2-2A', b_score_str: '2-2B')
        elimination.games.create(round: 3, gameNo: 1, a_team: team1, b_team: team4, win_team: team1, lose_team: team4, a_result: 'WIN', b_result: 'LOSE', a_score_str: '3-1A', b_score_str: '3-1B')
      end

      it '試合結果が正しく表示されている' do
        visit elimination_path(elimination)
        expect(find(:test_id, 'tournament-status')).to have_content "終了"

        expect(find(:test_id, '1-2-game')).to match_css('.r-top')
        expect(find(:test_id, '1-2-game')).to_not match_css('.r-bottom')
        expect(find(:test_id, '1-2-a-score')).to match_css('.r-left.r-bottom')
        expect(find(:test_id, '1-2-b-score')).to_not match_css('.r-left.r-top')
        expect(find(:test_id, '1-2-a-score')).to have_content('1-2A')
        expect(find(:test_id, '1-2-b-score')).to have_content('1-2B')

        expect(page).to have_css('[data-testid="2-1-game"].r-top')
        expect(page).to_not have_css('[data-testid="2-1-game"].r-bottom')
        expect(find(:test_id, '2-1-a-score')).to match_css('.r-left.r-bottom')
        expect(find(:test_id, '2-1-b-score')).to_not match_css('.r-left.r-top')
        expect(find(:test_id, '2-1-a-score')).to have_content('2-1A')
        expect(find(:test_id, '2-1-b-score')).to have_content('2-1B')

        expect(page).to have_css('[data-testid="2-2-game"].r-top')
        expect(page).to_not have_css('[data-testid="2-2-game"].r-bottom')
        expect(find(:test_id, '2-2-a-score')).to match_css('.r-left.r-bottom')
        expect(find(:test_id, '2-2-b-score')).to_not match_css('.r-left.r-top')
        expect(find(:test_id, '2-2-a-score')).to have_content('2-2A')
        expect(find(:test_id, '2-2-b-score')).to have_content('2-2B')

        expect(find(:test_id, '3-1-a-score')).to match_css('.r-left.r-bottom')
        expect(find(:test_id, '3-1-b-score')).to_not match_css('.r-left.r-top')
        expect(find(:test_id, '3-1-a-score')).to have_content('3-1A')
        expect(find(:test_id, '3-1-b-score')).to have_content('3-1B')
      end
    end

    context '6チーム、下側チーム勝利' do
      let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 6, has_score: true) }

      before do
        team1 = elimination.teams[0]
        team2 = elimination.teams[1]
        team3 = elimination.teams[2]
        team4 = elimination.teams[3]
        team5 = elimination.teams[4]
        team6 = elimination.teams[5]

        elimination.games.create(round: 1, gameNo: 2, a_team: team2, b_team: team3, win_team: team3, lose_team: team2, a_result: 'LOSE', b_result: 'WIN', a_score_str: '1-2A', b_score_str: '1-2B')
        elimination.games.create(round: 1, gameNo: 3, a_team: team4, b_team: team5, win_team: team5, lose_team: team4, a_result: 'LOSE', b_result: 'WIN', a_score_str: '1-3A', b_score_str: '1-3B')
        elimination.games.create(round: 2, gameNo: 1, a_team: team1, b_team: team3, win_team: team3, lose_team: team1, a_result: 'LOSE', b_result: 'WIN', a_score_str: '2-1A', b_score_str: '2-1B')
        elimination.games.create(round: 2, gameNo: 2, a_team: team5, b_team: team6, win_team: team6, lose_team: team5, a_result: 'LOSE', b_result: 'WIN', a_score_str: '2-2A', b_score_str: '2-2B')
        elimination.games.create(round: 3, gameNo: 1, a_team: team3, b_team: team6, win_team: team6, lose_team: team3, a_result: 'LOSE', b_result: 'WIN', a_score_str: '3-1A', b_score_str: '3-1B')
      end

      it '試合結果が正しく表示されている' do
        visit elimination_path(elimination)
        expect(find(:test_id, 'tournament-status')).to have_content "終了"

        expect(find(:test_id, '1-2-game')).to_not match_css('.r-top')
        expect(find(:test_id, '1-2-game')).to match_css('.r-bottom')
        expect(find(:test_id, '1-2-a-score')).to_not match_css('.r-left.r-bottom')
        expect(find(:test_id, '1-2-b-score')).to match_css('.r-left.r-top')
        expect(find(:test_id, '1-2-a-score')).to have_content('1-2A')
        expect(find(:test_id, '1-2-b-score')).to have_content('1-2B')

        expect(find(:test_id, '1-3-game')).to_not match_css('.r-top')
        expect(find(:test_id, '1-3-game')).to match_css('.r-bottom')
        expect(find(:test_id, '1-3-a-score')).to_not match_css('.r-left.r-bottom')
        expect(find(:test_id, '1-3-b-score')).to match_css('.r-left.r-top')
        expect(find(:test_id, '1-3-a-score')).to have_content('1-3A')
        expect(find(:test_id, '1-3-b-score')).to have_content('1-3B')

        expect(page).to_not have_css('[data-testid="2-1-game"].r-top')
        # expect(page).to have_css('[data-testid="2-1-game"].r-bottom')
        expect(find(:test_id, '2-1-a-score')).to_not match_css('.r-left.r-bottom')
        expect(find(:test_id, '2-1-b-score')).to match_css('.r-left.r-top')
        expect(find(:test_id, '2-1-a-score')).to have_content('2-1A')
        expect(find(:test_id, '2-1-b-score')).to have_content('2-1B')

        expect(page).to_not have_css('[data-testid="2-2-game"].r-top')
        expect(page).to have_css('[data-testid="2-2-game"].r-bottom')
        expect(find(:test_id, '2-2-a-score')).to_not match_css('.r-left.r-bottom')
        expect(find(:test_id, '2-2-b-score')).to match_css('.r-left.r-top')
        expect(find(:test_id, '2-2-a-score')).to have_content('2-2A')
        expect(find(:test_id, '2-2-b-score')).to have_content('2-2B')

        expect(find(:test_id, '3-1-a-score')).to_not match_css('.r-left.r-bottom')
        expect(find(:test_id, '3-1-b-score')).to match_css('.r-left.r-top')
        expect(find(:test_id, '3-1-a-score')).to have_content('3-1A')
        expect(find(:test_id, '3-1-b-score')).to have_content('3-1B')
      end
    end

  end

  describe "トーナメント管理者認証" do
    example do
      visit root_path

      click_on "トーナメント表作成"
      expect(page).to have_selector 'h1', text: "トーナメント表作成"

      fill_in '大会名', with: "全米オープン"
      fill_in '更新パスワード', with: "PASSWORD"
      click_on "作成"

      expect(page).to have_selector 'h1', text: "全米オープン"
      expect(find(:test_id, '1-1-game')).to have_link ''
      # show_me_the_cookies

      elimination = Elimination.first
      cookie_name = "elimination_#{elimination.id}"
      cookie = get_me_the_cookie(cookie_name)
      expect(cookie[:value]).to eq "PASSWORD"

      # 他のブラウザでは参照専用になっている。
      delete_cookie(cookie_name)
      visit elimination_path(elimination)

      expect(page).to_not have_link '設定'
      expect(page).to_not have_link 'チーム'
      expect(find(:test_id, '1-1-game')).to_not have_link ''

      # 更新パスワードの認証
      click_on "更新"

      fill_in '更新パスワード', with: "wrong_pw"
      click_on "送信"
      expect(page).to have_content 'パスワードが不一致です'

      fill_in '更新パスワード', with: "PASSWORD"
      click_on "送信"

      expect(page).to have_link '設定'
      expect(page).to have_link 'チーム'
      expect(find(:test_id, '1-1-game')).to have_link ''

      # 更新パスワードの変更
      click_on "設定"
      fill_in '更新パスワード', with: "new-pw"
      click_on "更新"

      expect(page).to have_selector 'h1', text: "全米オープン"
      expect(find(:test_id, '1-1-game')).to have_link ''
      cookie = get_me_the_cookie(cookie_name)
      expect(cookie[:value]).to eq "new-pw"

      # トーナメント削除
      click_on "設定"
      click_on "削除"

      page.accept_confirm
      expect(page).to have_content "トーナメントを削除しました"
      cookie = get_me_the_cookie(cookie_name)
      expect(cookie).to eq nil
    end
  end

end
