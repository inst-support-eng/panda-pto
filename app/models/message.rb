class Message < ApplicationRecord
  has_many :users

  def self.to_csv; end
end
