class ApplicationController < ActionController::Base
  before_action :get_bookmark


  private

  def get_bookmark
    @bookmark = Bookmark.new(cookies)
    @bookmarked_tournament_ids = @bookmark.all
  end

end
