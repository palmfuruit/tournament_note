class Roundrobins::DrawsController < ApplicationController
  def show
    roundrobin = Roundrobin.find_by(id: params[:roundrobin_id])
    unless roundrobin
      flash[:warning] = "リーグが見つかりません。"
      redirect_to root_path and return
    end
    roundrobin.tournament.update_last_access_day

    @round = 1
    @roundrobin = RoundrobinDecorator.new(roundrobin)
  end

  def update
    roundrobin = Roundrobin.find_by(id: params[:roundrobin_id])
    unless roundrobin
      flash[:warning] = "リーグが見つかりません。"
      redirect_to root_path and return
    end

    @round = params[:round].to_i
    @roundrobin = RoundrobinDecorator.new(roundrobin)
  end

end
