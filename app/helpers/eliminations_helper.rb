module EliminationsHelper
  include ApplicationHelper

  def border_top_bottom__a_win_b_win(game)
    if (game)
      if (game["a_result"] == 'WIN')
        "r-top"
      elsif (game["b_result"] == 'WIN')
        "r-bottom"
      end
    end
  end

  def border_top__a_win(game)
    if (game)
      if (game["a_result"] == 'WIN')
        "r-top"
      end
    end
  end

  def border_bottom__b_win(game)
    if (game)
      if (game["b_result"] == 'WIN')
        "r-bottom"
      end
    end
  end

  def border_left_bottom__a_win(game)
    if (game)
      if (game["a_result"] == 'WIN')
        "r-left r-bottom"
      end
    end
  end

  def border_left_top__b_win(game)
    if (game)
      if (game["b_result"] == 'WIN')
        "r-left r-top"
      end
    end
  end


end
