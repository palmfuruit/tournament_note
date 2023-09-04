class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # create前にset_idメソッドを呼び出す
  before_create :set_id

  private
  def set_id
    # id未設定、または、すでに同じidのレコードが存在する場合はループに入る
    while self.id.blank? || self.class.find_by(id: self.id).present? do
      # ランダムな20文字をidに設定し、whileの条件検証に戻る
      self.id = SecureRandom.alphanumeric(10).downcase
    end
  end
end
