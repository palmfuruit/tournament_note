require 'rails_helper'

RSpec.describe "リーグ", type: :system do
  include ApplicationHelper

  describe "リーグ作成" do
    example "デフォルト設定" do
      visit root_path

      click_on "リーグ表作成"
      expect(page).to have_selector 'h1', text: "リーグ表作成"

      fill_in '大会名', with: "予選リーグ "
      select '6', from: '参加チーム数'
      click_on "作成"

      expect(page).to have_selector 'h1', text: "予選リーグ"
      click_on "チーム"
      expect(page).to have_content "6チーム"
    end

    example "詳細設定あり" do
      visit root_path

      click_on "リーグ表作成"
      expect(page).to have_selector 'h1', text: "リーグ表作成"

      fill_in '大会名', with: "予選リーグ "
      select '5', from: '参加チーム数'

      check 'スコアを記録'
      select '10', from: '対戦数'
      select '勝点', from: '順位条件1'
      select '得失点差', from: '順位条件2'
      select '総得点', from: '順位条件3'
      select '直接対決', from: '順位条件4'
      click_on "作成"

      expect(page).to have_selector 'h1', text: "予選リーグ"
      expect(page).to have_content 'Round 1 / 10'

      click_on "設定"
      expect(page).to have_checked_field('スコアを記録')
      expect(page).to have_select('順位条件1', selected: '勝点')
      expect(page).to have_select('順位条件2', selected: '得失点差')
      expect(page).to have_select('順位条件3', selected: '総得点')
      expect(page).to have_select('順位条件4', selected: '直接対決')

      click_on "チーム"
      expect(page).to have_content "5チーム"
    end
  end

  describe "リーグ作成失敗" do
    example do
      visit root_path

      click_on "リーグ表作成"
      expect(page).to have_selector 'h1', text: "リーグ表作成"

      fill_in '大会名', with: ""
      click_on "作成"
      expect(page).to have_selector 'h1', text: "#{Date.today}"

    end
  end

  describe "大会名変更" do
    let!(:roundrobin) { create(:roundrobin, :with_teams, num_of_teams: 4) }
    example do
      visit roundrobin_path(roundrobin)

      expect(page).to have_selector 'h1', text: roundrobin.name
      click_on "設定"

      expect(page).to have_field '大会名'
      fill_in '大会名', with: "予選リーグ"
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

      expect(page).to have_field '大会名'
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

      expect(page).to have_field '大会名'
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

  describe "管理者認証" do
    example do
      visit root_path

      click_on "リーグ表作成"
      expect(page).to have_selector 'h1', text: "リーグ表作成"

      fill_in '大会名', with: "全米オープン"
      fill_in '管理者パスワード', with: "PASSWORD"
      click_on "作成"

      expect(page).to have_selector 'h1', text: "全米オープン"
      expect(find('#game-1-2')).to have_link ''
      # show_me_the_cookies

      roundrobin = Roundrobin.first
      cookie_name = "roundrobin_#{roundrobin.id}"
      cookie = get_me_the_cookie(cookie_name)
      expect(cookie[:value]).to eq "PASSWORD"

      # 他のブラウザでは参照専用になっている。
      delete_cookie(cookie_name)
      visit roundrobin_path(roundrobin)

      expect(page).to_not have_link '設定'
      expect(page).to_not have_link 'チーム'
      expect(find('#game-1-2')).to_not have_link ''

      # 管理者パスワードの認証
      click_on "管理者"

      fill_in '管理者パスワード', with: "wrong_pw"
      click_on "送信"
      expect(page).to have_content 'パスワードが不一致です'

      fill_in '管理者パスワード', with: "PASSWORD"
      click_on "送信"

      expect(page).to have_link '設定'
      expect(page).to have_link 'チーム'
      expect(find('#game-1-2')).to have_link ''

      # 管理者パスワードの変更
      click_on "設定"
      fill_in '管理者パスワード', with: "new-pw"
      click_on "更新"

      expect(page).to have_selector 'h1', text: "全米オープン"
      expect(find('#game-1-2')).to have_link ''
      cookie = get_me_the_cookie(cookie_name)
      expect(cookie[:value]).to eq "new-pw"

      # リーグ削除
      click_on "設定"
      click_on "削除"

      page.accept_confirm
      expect(page).to have_content "リーグを削除しました"
      cookie = get_me_the_cookie(cookie_name)
      expect(cookie).to eq nil
    end

  end
end
