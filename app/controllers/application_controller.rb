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

  def add_tournament_bookmark(tournament_id)
    @tournament_bookmarks.push(tournament_id)
    cookies.permanent[:bookmark_tournaments] = @tournament_bookmarks
  end

  def delete_tournament_bookmark(tournament_id)
    @tournament_bookmarks.delete(tournament_id)

    if @tournament_bookmarks.present?
      cookies.permanent[:bookmark_tournaments] = @tournament_bookmarks
    else
      cookies.delete :bookmark_tournaments
    end
  end

  private

  def get_bookmark
    @tournament_bookmarks = []

    if cookies.permanent[:bookmark_tournaments]
      @tournament_bookmarks = cookies.permanent[:bookmark_tournaments].split('&')
    end

    # 削除されているトーナメントを、CookieのBookmarkから削除する。
    @tournament_bookmarks.each do |tournament|
      unless Tournament.find_by(id: tournament)
        delete_tournament_bookmark(tournament)
      end
    end
  end

end
