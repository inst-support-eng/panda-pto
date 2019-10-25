class PtoRequest < ApplicationRecord
  require 'csv'
  belongs_to :user

  # import requests from outside the system
  def self.import(file)
    CSV.foreach(file.path, encoding: 'UTF-8', headers: true, header_converters: :symbol, converters: :all) do |row|
      agent = User.find_by(email: row[:email])
      date = Calendar.find_by(date: row[:date])
      price = row[:price].to_i
      reason = row[:reason]

      next if agent.nil?
      next if date.nil?
      next if price.nil?
      next if date.signed_up_agents.include?(agent.name)

      PtoRequest.create(
        request_date: date.date.to_s,
        cost: price,
        user_id: agent.id,
        reason: "#{reason} - request imported by admin",
        excused: false
      )

      date.signed_up_total.nil? ? date.signed_up_total = 1 : date.signed_up_total += 1
      date.signed_up_agents.push(agent.name)
      date.save

      agent.bank_value -= price
      agent.save
    end
  end

  # create csv of requests
  def self.to_csv
    data = %w[name email request_date cost reason signed_up_total excused same_day created_at is_deleted]
    CSV.generate(headers: true) do |csv|
      csv << data

      all.each do |pto|
        csv << data.map { |attr| pto.send(attr) }
      end
    end
  end

  def name
    user.name
  end

  def email
    user.email
  end

  def same_day
    if request_date.to_s == created_at.in_time_zone('Mountain Time (US & Canada)').to_s[0, 10]
      TRUE
    else
      FALSE
    end
  end
end
