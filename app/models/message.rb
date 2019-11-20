class Message < ApplicationRecord
  has_many :users

  # create csv of messages
  def self.to_csv
    all_messages = Message.all

    CSV.generate do |csv|
      data = %w[author recipients message status created_at]
      csv << data.map(&:humanize)
      all_messages.each do |m|
        csv << m.attributes.values_at(*data)
      end
    end
  end
end
