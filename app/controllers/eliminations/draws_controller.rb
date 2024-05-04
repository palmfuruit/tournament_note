class Eliminations::DrawsController < ApplicationController

  def show
    elimination = Elimination.find_by(id: params[:elimination_id])
    unless elimination
      flash[:warning] = "トーナメントが見つかりません。"
      redirect_to root_path and return
    end
    elimination.tournament.update_last_access_day

    @elimination = EliminationDecorator.new(elimination)
  end

end
