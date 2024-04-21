class Authentication
  def initialize(cookies)
    @cookies = cookies
  end

  def set_password(id:, tournament_type:, password:)
    key = "#{tournament_type}_#{id}"

    if password.present?
      @cookies.permanent[key] = password
    else
      @cookies.delete key
    end
  end

  def clear_password(id:, tournament_type:)
    key = "#{tournament_type}_#{id}"
    @cookies.delete key
  end
end