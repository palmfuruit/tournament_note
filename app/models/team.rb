class Team < ApplicationRecord
  belongs_to :tournament
  delegate :elimination, to: :tournament

  validates :name, presence: true, length: { maximum: 10 }
  validate :max_num_of_teams, on: :create

  def str_entruNo_and_name
    "[#{self.entryNo}]　#{self.name}"
  end

  def max_num_of_teams
    if tournament && tournament.teams.count >= MAX_TEAMS
      errors.add :base, :max_teams, message: "登録可能なチーム数を超えています。"
    end
  end
end
