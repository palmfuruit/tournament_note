require 'rails_helper'

RSpec.describe Roundrobin, type: :model do
  describe 'destroy' do
    let!(:roundrobin) { create(:roundrobin, :with_teams, num_of_teams: 4) }
    before do
      @tournament = roundrobin.tournament
      team1 = roundrobin.teams[0]
      team2 = roundrobin.teams[1]

      @tournament.games.create(round: 1, gameNo: nil, a_team: team1, b_team: team2, win_team: team1, lose_team: team2, a_result: 'WIN', b_result: 'LOSE')
    end

    it "トーナメントを削除したときに関連するTeamとgameも削除される。" do
      expect { @tournament.destroy }.to change { Roundrobin.count }.by(-1).and change { Team.count }.by(-4).and change { Game.count }.by(-1)
    end

  end
end
