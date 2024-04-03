class TeamsShuffle
  def initialize(tournament)
    @tournament = tournament
  end

  def shuffle
    @teams = @tournament.teams&.order(:entryNo)

    entry_numbers = (1..@teams.size).to_a
    ActiveRecord::Base.transaction do
      @teams.each do |team|
        number = entry_numbers.sample
        team.update(entryNo: number)
        entry_numbers.delete(number)
      end
    end
  end

end