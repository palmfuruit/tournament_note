class Bookmark
  def initialize(cookies)
    @cookies = cookies

    if @cookies.permanent[:bookmarks]
      @tournament_ids = @cookies.permanent[:bookmarks].split('&')
    else
      @tournament_ids = []
    end

    # 削除されているトーナメントを、CookieのBookmarkから削除する。
    @tournament_ids.each do |tournament_id|
      unless Tournament.find_by(id: tournament_id)
        delete(tournament_id)
      end
    end
  end


  def add(tournament_id)
    @tournament_ids.push(tournament_id)
    @cookies.permanent[:bookmarks] = @tournament_ids
  end


  def delete(tournament_id)
    @tournament_ids.delete(tournament_id)

    if @tournament_ids.present?
      @cookies.permanent[:bookmarks] = @tournament_ids
    else
      @cookies.delete :bookmarks
    end
  end

  def all
    @tournament_ids
  end


end