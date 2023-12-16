class ApplicationController < ActionController::Base
  def set_cookie(id, password, tournament_type)
    key = "#{tournament_type}_#{id}"

    if password.present?
      cookies.permanent[key] = password
    else
      cookies.delete key
    end
  end

  def clear_cookie(id, tournament_type)
    key = "#{tournament_type}_#{id}"
    cookies.delete key
  end

end
