require 'rails_helper'

RSpec.describe Team, type: :model do
    it "has a valid factory" do
      expect(build(:team)).to be_valid
    end

    describe "Validation" do
      context 'トーナメントなし' do
        let(:team) { build(:team, tournament: nil) }
        it "エラーになる" do
          expect(team.valid?).to be_falsey
        end
      end
      context '名前が空' do
        let(:team) { FactoryBot.build(:team, name: "") }
        it "エラーになる" do
          expect(team.valid?).to be_falsey
        end
      end
      context '名前の長さが上限' do
        let(:team) { FactoryBot.build(:team, name: "a" * 10) }
        it "バリデーションをパスする" do
          expect(team.valid?).to be_truthy
        end
      end
      context '名前が長過ぎる' do
        let(:team) { FactoryBot.build(:team, name: "a" * 11) }
        it "エラーになる" do
          expect(team.valid?).to be_falsey
        end
      end
      context 'チーム数が上限を超える' do
        let(:tournament) { FactoryBot.create(:tournament, :with_teams, num_of_teams: 16) }
        let(:team) { FactoryBot.build(:team, tournament: tournament) }
        it "エラーになる" do
          expect(team.valid?).to be_falsey
        end
      end
    end
end
