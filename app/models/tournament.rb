class Tournament < ApplicationRecord
  has_one :elimination, dependent: :destroy
  has_one :roundrobin, dependent: :destroy
  has_many :teams, dependent: :delete_all
  has_many :games, dependent: :delete_all

  enum tournament_type: [:elimination, :roundrobin]

  def set_entryNo
    Tournament.no_touching do
      teams.order(:entryNo, :created_at).each.with_index(1) do |team, i|
        team.entryNo = i
        team.save(touch: false)
      end
    end
  end

  def name
    case tournament_type
    when "elimination" then
      elimination.name
    when "roundrobin" then
      roundrobin.name
    end
  end

  def update_last_access_day
    today = Time.zone.today
    unless accessed_on == today
      update(accessed_on: today)
    end
  end
end
