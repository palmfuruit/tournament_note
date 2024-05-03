class Roundrobin < ApplicationRecord
  belongs_to :tournament
  delegate :teams, to: :tournament
  delegate :games, to: :tournament

  validates :name, presence: true, length: { maximum: 16 }
  validates :has_score, inclusion: { in: [true, false] }
  validates :num_of_round, numericality: { only_integer: true, in: 1..10 }
  validates :password, length: { maximum: 16 }

  # Constant
  enum rank1: { none: 0, win_points: 1, win_rate: 2, goal_diff: 11, total_goals: 12, head_to_head: 90 }, _prefix: true
  enum rank2: { none: 0, win_points: 1, win_rate: 2, goal_diff: 11, total_goals: 12, head_to_head: 90 }, _prefix: true
  enum rank3: { none: 0, win_points: 1, win_rate: 2, goal_diff: 11, total_goals: 12, head_to_head: 90 }, _prefix: true
  enum rank4: { none: 0, win_points: 1, win_rate: 2, goal_diff: 11, total_goals: 12, head_to_head: 90 }, _prefix: true

  RANK_CONDITION = {
    'none' => 'なし',
    'win_points' => '勝点',
    'win_rate' => '勝率',
    'goal_diff' => '得失点差',
    'total_goals' => '総得点',
    'head_to_head' => '直接対決',
  }


  def status
    if games.count == 0
      sts = "NOT_STARTED"
    elsif games.count >= (1..(teams.size-1)).sum * num_of_round
      sts = "FINISHED"
    else
      sts = "ONGOING"
    end
    sts
  end

end
