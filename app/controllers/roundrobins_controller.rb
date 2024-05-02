class RoundrobinsController < ApplicationController
  before_action :authenticate_owner, only: [:edit, :update, :destroy, :reset]

  def index
    @num_of_roundrobins = Roundrobin.all.size
    @roundrobins = Roundrobin.all.order(created_at: :desc).page(params[:page])
  end

  def show
    @roundrobin = Roundrobin.find_by(id: params[:id])
    unless @roundrobin
      flash[:warning] = "リーグが見つかりません。"
      redirect_to root_path and return
    end

    @teams = @roundrobin.teams.order(:entryNo).map(&:attributes)
    @games = @roundrobin.games.map(&:attributes)
    @round = 1
    @roundrobin.tournament.update_last_access_day
  end

  def change_round
    @roundrobin = Roundrobin.find_by(id: params[:id])
    @round = params[:round].to_i

    unless @roundrobin
      flash[:warning] = "リーグが見つかりません。"
      redirect_to root_path and return
    end

    @teams = @roundrobin.teams.order(:entryNo).map(&:attributes)
    @games = @roundrobin.games.map(&:attributes)
  end

  def new
    @roundrobin = Roundrobin.new
  end

  def create
    ActiveRecord::Base.transaction do
      tournament = Tournament.create(tournament_type: :roundrobin)
      @roundrobin = tournament.build_roundrobin(roundrobin_params)
      num_of_teams = params[:num_of_teams].to_i

      if @roundrobin.save
        authenticaion = Authentication.new(cookies)
        authenticaion.set_password(id: @roundrobin.id, tournament_type: 'roundrobin', password: @roundrobin.password)

        (1..num_of_teams).each do |i|
          @roundrobin.teams.create(name: "Team#{i}", entryNo: i)
        end
        redirect_to roundrobin_path(@roundrobin)
      else
        render 'new', status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  def edit
    @roundrobin = Roundrobin.find_by(id: params[:id])
    unless @roundrobin
      flash[:warning] = "リーグが見つかりません。"
      redirect_to root_path
    end
  end

  def update
    @roundrobin = Roundrobin.find_by(id: params[:id])

    if @roundrobin.update(roundrobin_params)
      authenticaion = Authentication.new(cookies)
      authenticaion.set_password(id: @roundrobin.id, tournament_type: 'roundrobin', password: @roundrobin.password)

      redirect_to roundrobin_path(@roundrobin)
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    @roundrobin = Roundrobin.find_by(id: params[:id])
    @roundrobin.tournament.destroy
    authenticaion = Authentication.new(cookies)
    authenticaion.clear_password(id: @roundrobin.id, tournament_type: 'roundrobin')

    redirect_to root_path, flash: { info: 'リーグを削除しました' }
  end

  def reset
    @roundrobin = Roundrobin.find_by(id: params[:id])
    @roundrobin.games.delete_all

    redirect_to roundrobin_path(@roundrobin), flash: { info: 'リーグをリセットしました' }
  end

  def share
    @roundrobin = Roundrobin.find_by(id: params[:id])
  end


  ### Private Method
  private

  def roundrobin_params
    ret_p = params.require(:roundrobin).permit(:name, :description, :has_score, :num_of_round, :rank1, :rank2, :rank3, :rank4, :password)
    if ret_p[:name].blank?
      ret_p[:name] = "#{Date.today}"
    end
    ret_p
  end



  def authenticate_owner
    roundrobin = Roundrobin.find_by(id: params[:id])
    unless view_context.tournament_owner?(roundrobin.tournament)
      redirect_to roundrobin_path(roundrobin)
    end
  end

end
