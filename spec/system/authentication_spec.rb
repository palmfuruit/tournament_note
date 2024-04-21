require 'rails_helper'

RSpec.describe "Authentication", type: :system do


  describe "トーナメントの認証" do
    let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 4) }

    example do
      visit elimination_path(elimination)

      expect(page).to have_selector 'h1', text: elimination.name
      # show_me_the_cookies

      # 更新パスワードの設定
      click_on "設定"
      fill_in '更新パスワード', with: "PASSWORD"
      click_on "更新"

      expect(page).to have_link '設定'
      expect(page).to have_link 'チーム'
      expect(find(:test_id, '1-1-game', match: :first)).to have_link ''

      cookie_name = "elimination_#{elimination.id}"
      cookie = get_me_the_cookie(cookie_name)
      expect(cookie[:value]).to eq "PASSWORD"

      # 他のブラウザでは参照専用になっている。
      delete_cookie(cookie_name)
      visit elimination_path(elimination)

      expect(page).to_not have_link '設定'
      expect(page).to_not have_link 'チーム'
      expect(find(:test_id, '1-1-game', match: :first)).to_not have_link ''

      # 更新パスワードの認証
      click_on "更新"

      fill_in '更新パスワード', with: "wrong_pw"
      click_on "送信"
      expect(page).to have_content 'パスワードが不一致です'

      fill_in '更新パスワード', with: "PASSWORD"
      click_on "送信"

      expect(page).to have_link '設定'
      expect(page).to have_link 'チーム'
      expect(find(:test_id, '1-1-game', match: :first)).to have_link ''

      # 更新パスワードの変更
      click_on "設定"
      fill_in '更新パスワード', with: "new-pw"
      click_on "更新"

      expect(page).to have_selector 'h1', text: elimination.name
      expect(find(:test_id, '1-1-game', match: :first)).to have_link ''
      cookie = get_me_the_cookie(cookie_name)
      expect(cookie[:value]).to eq "new-pw"

      # トーナメント削除
      click_on "設定"
      expect(page).to have_content "トーナメントを削除"
      click_on "削除"

      page.accept_confirm
      expect(page).to have_content "トーナメントを削除しました"
      cookie = get_me_the_cookie(cookie_name)
      expect(cookie).to eq nil
    end
  end

  describe "リーグ戦の認証" do
    let!(:roundrobin) { create(:roundrobin, :with_teams, num_of_teams: 4) }

    example do
      visit roundrobin_path(roundrobin)

      expect(page).to have_selector 'h1', text: roundrobin.name

      # 更新パスワードの設定
      click_on "設定"
      fill_in '更新パスワード', with: "PASSWORD"
      click_on "更新"

      expect(page).to have_link '設定'
      expect(page).to have_link 'チーム'
      expect(find('#game-1-2')).to have_link ''

      cookie_name = "roundrobin_#{roundrobin.id}"
      cookie = get_me_the_cookie(cookie_name)
      expect(cookie[:value]).to eq "PASSWORD"

      # 他のブラウザでは参照専用になっている。
      delete_cookie(cookie_name)
      visit roundrobin_path(roundrobin)

      expect(page).to_not have_link '設定'
      expect(page).to_not have_link 'チーム'
      expect(find('#game-1-2')).to_not have_link ''

      # 更新パスワードの認証
      click_on "更新"

      fill_in '更新パスワード', with: "wrong_pw"
      click_on "送信"
      expect(page).to have_content 'パスワードが不一致です'

      fill_in '更新パスワード', with: "PASSWORD"
      click_on "送信"

      expect(page).to have_link '設定'
      expect(page).to have_link 'チーム'
      expect(find('#game-1-2')).to have_link ''

      # 更新パスワードの変更
      click_on "設定"
      fill_in '更新パスワード', with: "new-pw"
      click_on "更新"

      expect(page).to have_selector 'h1', text: roundrobin.name
      expect(find('#game-1-2')).to have_link ''
      cookie = get_me_the_cookie(cookie_name)
      expect(cookie[:value]).to eq "new-pw"

      # リーグ削除
      click_on "設定"
      expect(page).to have_content "リーグを削除"
      click_on "削除"

      page.accept_confirm
      expect(page).to have_content "リーグを削除しました"
      cookie = get_me_the_cookie(cookie_name)
      expect(cookie).to eq nil
    end
  end

end


