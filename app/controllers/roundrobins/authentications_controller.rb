class Roundrobins::AuthenticationsController < ApplicationController
  def new
    @roundrobin = Roundrobin.find_by(id: params[:roundrobin_id])
  end

  def create
    @roundrobin = Roundrobin.find_by(id: params[:roundrobin_id])
    unless @roundrobin
      flash[:warning] = "リーグが見つかりません。"
      redirect_to root_path and return
    end

    @error_message = nil
    if @roundrobin.password == params[:password]
      authenticaion = Authentication.new(cookies)
      authenticaion.set_password(id: @roundrobin.id, tournament_type: 'roundrobin', password: params[:password])

      redirect_to roundrobin_path(@roundrobin)
    else
      @error_message = "パスワードが不一致です"

      render 'new', status: :unprocessable_entity
    end
  end
end