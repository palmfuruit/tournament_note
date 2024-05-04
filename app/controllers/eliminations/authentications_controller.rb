class Eliminations::AuthenticationsController < ApplicationController
  def new
    @elimination = Elimination.find_by(id: params[:elimination_id])
  end

  def create
    @elimination = Elimination.find_by(id: params[:elimination_id])
    unless @elimination
      flash[:warning] = "トーナメントが見つかりません。"
      redirect_to root_path and return
    end

    @error_message = nil
    if @elimination.password == params[:password]
      authenticaion = Authentication.new(cookies)
      authenticaion.set_password(id: @elimination.id, tournament_type: 'elimination', password: params[:password])

      redirect_to elimination_draw_path(@elimination)
    else
      @error_message = "パスワードが不一致です"

      render 'new', status: :unprocessable_entity
    end
  end
end

