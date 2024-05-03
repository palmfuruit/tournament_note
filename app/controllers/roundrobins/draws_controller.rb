class Roundrobins::DrawsController < ApplicationController
  def show
    @roundrobin = Roundrobin.find_by(id: params[:roundrobin_id])
    unless @roundrobin
      flash[:warning] = "リーグが見つかりません。"
      redirect_to root_path and return
    end

    @teams = @roundrobin.teams.order(:entryNo).map(&:attributes)
    @games = @roundrobin.games.map(&:attributes)
    @round = 1
    @roundrobin.tournament.update_last_access_day
  end

  def update
    @roundrobin = Roundrobin.find_by(id: params[:roundrobin_id])
    unless @roundrobin
      flash[:warning] = "リーグが見つかりません。"
      redirect_to root_path and return
    end

    @teams = @roundrobin.teams.order(:entryNo).map(&:attributes)
    @games = @roundrobin.games.map(&:attributes)
    @round = params[:round].to_i

  end

end
