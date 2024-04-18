class TournamentDecorator < ApplicationDecorator
  delegate_all

  def bookmarked?(bookmarked_tournament_ids)
    bookmarked_tournament_ids.include?(id.to_s)
  end

end
