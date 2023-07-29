module EliminationsGamesHelper

  def a_score(game)
    game ? "#{game["a_score"]} #{game["a_sub_score"]}" : nil
  end

  def b_score(game)
    game ? "#{game["b_score"]} #{game["b_sub_score"]}" : nil
  end

end
