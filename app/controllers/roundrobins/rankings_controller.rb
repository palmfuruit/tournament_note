class Roundrobins::RankingsController < ApplicationController

  def show
    @roundrobin = Roundrobin.find_by(id: params[:roundrobin_id])
    unless @roundrobin
      flash[:warning] = "リーグが見つかりません。"
      redirect_to root_path and return
    end

    @ranking = Ranking.new(@roundrobin)
  end

end