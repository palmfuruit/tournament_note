class EliminationsController < ApplicationController
  before_action :authenticate_owner, only: [:edit, :update, :destroy, :reset]

  def index
    @num_of_eliminations = Elimination.all.size
    @eliminations = Elimination.all.order(created_at: :desc).page(params[:page])
  end

  def show
    redirect_to elimination_draw_path(params[:id])
  end

  def new
    @elimination = Elimination.new
  end

  def create
    ActiveRecord::Base.transaction do
      tournament = Tournament.create(tournament_type: :elimination)
      @elimination = tournament.build_elimination(elimination_params)
      num_of_teams = params[:num_of_teams].to_i

      if @elimination.save
        authenticaion = Authentication.new(cookies)
        authenticaion.set_password(id: @elimination.id, tournament_type: 'elimination', password: @elimination.password)

        (1..num_of_teams).each do |i|
          @elimination.teams.create(name: "Team#{i}", entryNo: i)
        end
        redirect_to elimination_draw_path(@elimination)
      else
        render 'new', status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  def edit
    @elimination = Elimination.find_by(id: params[:id])
    unless @elimination
      flash[:warning] = "トーナメントが見つかりません。"
      redirect_to root_path
    end
  end

  def update
    @elimination = Elimination.find_by(id: params[:id])

    if @elimination.update(elimination_params)
      authenticaion = Authentication.new(cookies)
      authenticaion.set_password(id: @elimination.id, tournament_type: 'elimination', password: @elimination.password)

      redirect_to elimination_draw_path(@elimination)
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    @elimination = Elimination.find_by(id: params[:id])
    @elimination.tournament.destroy
    authenticaion = Authentication.new(cookies)
    authenticaion.clear_password(id: @elimination.id, tournament_type: 'elimination')

    redirect_to root_path, flash: { info: 'トーナメントを削除しました' }
  end

  def reset
    @elimination = Elimination.find_by(id: params[:id])
    @elimination.games.delete_all

    redirect_to elimination_draw_path(@elimination), flash: { info: 'トーナメントをリセットしました' }
  end

  def share
    @elimination = Elimination.find_by(id: params[:id])
  end


  ### Private Method

  private

  def elimination_params
    ret_p = params.require(:elimination).permit(:name, :description, :has_score, :password)
    if ret_p[:name].blank?
      ret_p[:name] = "#{Date.today}"
    end
    ret_p
  end

  def authenticate_owner
    elimination = Elimination.find_by(id: params[:id])
    unless view_context.tournament_owner?(elimination.tournament)
      redirect_to elimination_draw_path(elimination)
    end
  end

end
