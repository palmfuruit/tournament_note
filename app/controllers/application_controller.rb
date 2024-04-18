class ApplicationController < ActionController::Base
  before_action :get_bookmark

  def set_cookie_admin(id, password, tournament_type)
    key = "#{tournament_type}_#{id}"

    if password.present?
      cookies.permanent[key] = password
    else
      cookies.delete key
    end
  end

  def clear_cookie_admin(id, tournament_type)
    key = "#{tournament_type}_#{id}"
    cookies.delete key
  end


  private

  def get_bookmark
    @bookmark = Bookmark.new(cookies)
    @bookmarked_tournament_ids = @bookmark.all
  end

end
