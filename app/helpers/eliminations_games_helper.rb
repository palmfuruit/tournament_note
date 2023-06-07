module EliminationsGamesHelper

  def a_score(game)
    game ? "#{game["a_score"].to_s} #{game["a_sub_score"]}" : nil
  end

  def b_score(game)
    game ? "#{game["b_score"].to_s} #{game["b_sub_score"]}" : nil
  end

end
