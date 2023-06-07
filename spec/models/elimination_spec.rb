require 'rails_helper'

RSpec.describe Elimination, type: :model do
  describe 'destroy' do
    let!(:elimination) { create(:elimination, :with_teams, num_of_teams: 4) }
    before do
      team1 = elimination.teams[0]
      team2 = elimination.teams[1]

      elimination.games.create(round: 1, gameNo: 1, a_team: team1, b_team: team2, win_team: team1, lose_team: team2, a_result: 'WIN', b_result: 'LOSE')
    end

    it "トーナメントを削除したときに関連するTeamとgameも削除される。" do
      expect { elimination.destroy }.to change { Elimination.count }.by(-1).and change { Team.count }.by(-4).and change { Game.count }.by(-1)
    end
  end
end
