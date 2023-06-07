class Elimination < ApplicationRecord
  has_many :teams, dependent: :delete_all
  has_many :games, dependent: :delete_all

  validates :name, presence: true, length: { maximum: 16 }

  # constant
  def self.seed_table_256
    [
      1, 256, 129, 128, 65, 192, 193, 64, 33, 224, 161, 96, 97, 160, 225, 32,
      17, 240, 145, 112, 81, 176, 209, 48, 49, 208, 177, 80, 113, 144, 241, 16,
      9, 248, 137, 120, 73, 184, 201, 56, 41, 216, 169, 88, 105, 152, 233, 24,
      25, 232, 153, 104, 89, 168, 217, 40, 57, 200, 185, 72, 121, 136, 249, 8,
      5, 252, 133, 124, 69, 188, 197, 60, 37, 220, 165, 92, 101, 156, 229, 28,
      21, 236, 149, 108, 85, 172, 213, 44, 53, 204, 181, 76, 117, 140, 245, 12,
      13, 244, 141, 116, 77, 180, 205, 52, 45, 212, 173, 84, 109, 148, 237, 20,
      29, 228, 157, 100, 93, 164, 221, 36, 61, 196, 189, 68, 125, 132, 253, 4,
      3, 254, 131, 126, 67, 190, 195, 62, 35, 222, 163, 94, 99, 158, 227, 30,
      19, 238, 147, 110, 83, 174, 211, 46, 51, 206, 179, 78, 115, 142, 243, 14,
      11, 246, 139, 118, 75, 182, 203, 54, 43, 214, 171, 86, 107, 150, 235, 22,
      27, 230, 155, 102, 91, 166, 219, 38, 59, 198, 187, 70, 123, 134, 251, 6,
      7, 250, 135, 122, 71, 186, 199, 58, 39, 218, 167, 90, 103, 154, 231, 26,
      23, 234, 151, 106, 87, 170, 215, 42, 55, 202, 183, 74, 119, 138, 247, 10,
      15, 242, 143, 114, 79, 178, 207, 50, 47, 210, 175, 82, 111, 146, 239, 18,
      31, 226, 159, 98, 95, 162, 223, 34, 63, 194, 191, 66, 127, 130, 255, 2
    ]
  end

  # Function
  def final_round
    teams.size >= 2 ? Math.log2(teams.length).ceil : 0
  end

  def status
    if games.count == 0
      sts = "NOT_STARTED"
    else
      if games.find_by(round: final_round)
        sts = "FINISHED"
      else
        sts = "ONGOING"
      end
    end

    sts
  end

  def seed_table
    return [] if teams.length < 2

    num_of_teams_bye = 2 ** final_round # Team数以上で最小の2のべき乗
    seed_table = self.class.seed_table_256.select { |n| n <= num_of_teams_bye }

    work = []
    num_of_teams_bye.times do |i|
      hash_temp = {}
      hash_temp.store(:seed, seed_table[i])
      hash_temp.store(:round1_gameNo, (i / 2) + 1)
      hash_temp.store(:round1_side, i.even? ? "a" : "b")
      hash_temp.store(:round2_gameNo, (i / 4) + 1)
      hash_temp.store(:round2_side, (i / 2).even? ? "a" : "b")
      work[i] = hash_temp
    end
    work.select { |n| n[:seed] <= teams.size } # Team数を超える文をカット
  end

  def set_entryNo
    Elimination.no_touching do
      teams.order(:entryNo, :created_at).each.with_index(1) do |team, i|
        team.entryNo = i
        team.save(touch: false)
      end
    end
  end
end
