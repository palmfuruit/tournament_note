class Game < ApplicationRecord
  belongs_to :tournament, touch: true
  belongs_to :a_team, class_name: "Team", optional: true
  belongs_to :b_team, class_name: "Team", optional: true
  belongs_to :win_team, class_name: "Team", optional: true
  belongs_to :lose_team, class_name: "Team", optional: true

  delegate :elimination, to: :tournament

  validates :win_team_id, presence: true
  validates :a_score_num, numericality: { only_integer: true, in: 0..999 }
  validates :b_score_num, numericality: { only_integer: true, in: 0..999 }

  def has_score_num?
    tournament.roundrobin? && tournament.roundrobin.has_score
  end

end
