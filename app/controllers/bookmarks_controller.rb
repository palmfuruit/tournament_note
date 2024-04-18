class BookmarksController < ApplicationController
  def create
    @tournament = Tournament.find_by(id: params[:tournament_id])
    unless @tournament
      flash[:warning] = "トーナメントが見つかりません。"
      redirect_to root_path and return
    end

    bookmark = Bookmark.new(cookies)
    bookmark.add(@tournament.id)
    @bookmarked_tournament_ids = bookmark.all

    render 'toggled'
  end

  def destroy
    @tournament = Tournament.find_by(id: params[:tournament_id])
    unless @tournament
      flash[:warning] = "トーナメントが見つかりません。"
      redirect_to root_path and return
    end

    bookmark = Bookmark.new(cookies)
    bookmark.delete(@tournament.id)
    @bookmarked_tournament_ids = bookmark.all

    render 'toggled'
  end
end
