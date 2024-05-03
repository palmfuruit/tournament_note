require 'rails_helper'

RSpec.describe "Bookmark", type: :system do

  describe "Bookmark登録、解除" do
    let!(:elimination1) { create(:elimination) }
    let!(:elimination2) { create(:elimination) }
    let!(:roundrobin1) { create(:roundrobin) }

    example do
      # Elimination1 ブックマークする。
      visit elimination_path(elimination1)
      expect(page).to have_button 'ブックマーク'
      click_on "ブックマーク"

      expect(page).to have_button 'ブックマーク済'
      find('#dropdown-bookmark').click
      expect(page).to have_link elimination1.name

      # Elimination2 ブックマークする。
      visit elimination_path(elimination2)
      expect(page).to have_button 'ブックマーク'
      click_on "ブックマーク"

      expect(page).to have_button 'ブックマーク済'
      find('#dropdown-bookmark').click
      expect(page).to have_link elimination1.name
      expect(page).to have_link elimination2.name

      # Roundrobin1 ブックマークする。
      visit roundrobin_draw_path(roundrobin1)
      expect(page).to have_button 'ブックマーク'
      click_on "ブックマーク"

      expect(page).to have_button 'ブックマーク済'
      find('#dropdown-bookmark').click
      expect(page).to have_link elimination1.name
      expect(page).to have_link elimination2.name
      expect(page).to have_link roundrobin1.name

      # Elimination2 ブックマーク解除。
      visit elimination_path(elimination2)
      click_on "ブックマーク済"
      expect(page).to have_button 'ブックマーク'
      find('#dropdown-bookmark').click
      expect(page).to have_link elimination1.name
      expect(page).to_not have_link elimination2.name
      expect(page).to have_link roundrobin1.name

      # Elimination1 ブックマーク解除。
      visit elimination_path(elimination1)
      click_on "ブックマーク済"
      expect(page).to have_button 'ブックマーク'
      find('#dropdown-bookmark').click
      expect(page).to_not have_link elimination1.name
      expect(page).to_not have_link elimination2.name
      expect(page).to have_link roundrobin1.name

      # Roundrobin1 ブックマーク解除。
      click_on roundrobin1.name
      expect(page).to have_button 'ブックマーク済'
      click_on "ブックマーク済"
      expect(page).to have_button 'ブックマーク'
      expect(page.all('#dropdown-bookmark').empty?).to eq true

    end
  end

  describe "トーナメント(リーグ)削除されると、ブックマークも解除される。" do
    let!(:elimination1) { create(:elimination) }

    example do
      # Elimination1 ブックマークする。
      visit elimination_path(elimination1)
      expect(page).to have_button 'ブックマーク'
      click_on "ブックマーク"

      expect(page).to have_button 'ブックマーク済'
      find('#dropdown-bookmark').click
      expect(page).to have_link elimination1.name

      click_on "設定"
      expect(page).to have_field '大会名'
      click_on '削除'
      page.accept_confirm
      expect(page).to have_content "トーナメントを削除しました"

      expect(page.all('#dropdown-bookmark').empty?).to eq true
    end

  end

end