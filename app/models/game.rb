class Game < ApplicationRecord
  belongs_to :tournament, touch: true
  belongs_to :a_team, class_name: "Team", optional: true
  belongs_to :b_team, class_name: "Team", optional: true
  belongs_to :win_team, class_name: "Team", optional: true
  belongs_to :lose_team, class_name: "Team", optional: true

  delegate :elimination, to: :tournament

  validates :win_team_id, presence: true
end
