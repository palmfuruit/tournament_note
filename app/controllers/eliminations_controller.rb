class EliminationsController < ApplicationController
  before_action :authenticate_owner, only: [:edit, :update, :destroy, :reset]

  def index
    @num_of_eliminations = Elimination.all.size
    @eliminations = Elimination.all.order(created_at: :desc).page(params[:page])
  end

  def show
    @elimination = Elimination.find_by(id: params[:id])
    unless @elimination
      flash[:warning] = "トーナメントが見つかりません。"
      redirect_to root_path and return
    end

    @teams = @elimination.teams.order(:entryNo).map(&:attributes)
    @games = @elimination.games.map(&:attributes)
    @elimination.tournament.update_last_access_day
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
        set_cookie_admin(@elimination.id, @elimination.password, 'elimination')

        (1..num_of_teams).each do |i|
          @elimination.teams.create(name: "Team#{i}", entryNo: i)
        end
        redirect_to elimination_path(@elimination)
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
      set_cookie_admin(@elimination.id, @elimination.password, 'elimination')

      redirect_to elimination_path(@elimination)
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    @elimination = Elimination.find_by(id: params[:id])
    @elimination.tournament.destroy
    clear_cookie_admin(@elimination.id, 'elimination')

    redirect_to root_path, flash: { info: 'トーナメントを削除しました' }
  end

  def reset
    @elimination = Elimination.find_by(id: params[:id])
    @elimination.games.delete_all

    redirect_to elimination_path(@elimination), flash: { info: 'トーナメントをリセットしました' }
  end

  def share
    @elimination = Elimination.find_by(id: params[:id])
  end

  def admin
    @elimination = Elimination.find_by(id: params[:id])
  end

  def authentication
    @elimination = Elimination.find_by(id: params[:id])
    unless @elimination
      flash[:warning] = "トーナメントが見つかりません。"
      redirect_to root_path and return
    end

    @error_message = nil
    if @elimination.password == params[:password]
      set_cookie_admin(@elimination.id, params[:password], 'elimination')

      redirect_to elimination_path(@elimination)
    else
      @error_message = "パスワードが不一致です"

      render 'admin', status: :unprocessable_entity
    end

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
      redirect_to elimination_path(elimination)
    end
  end

end
