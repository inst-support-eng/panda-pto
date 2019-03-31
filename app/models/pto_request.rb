class PtoRequest < ApplicationRecord
  require 'csv'
  belongs_to :user

  def self.import(file)
    CSV.foreach(file.path, {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
      agent = User.find_by(:email => row[:email])
      date = Calendar.find_by(:date => row[:date])
      price = row[:shift].to_i
      
      PtoRequest.create(
        :request_date => date.date.to_s,
        :cost => price,
        :user_id => agent.id,
        :reason => "imported PTO request"
      )
      
      date.signed_up_total == nil ? date.signed_up_total = 1 : date.signed_up_total += 1
      date.signed_up_agents.push(agent.name)
      date.save
      
      agent.bank_value -= price
      agent.save

    end
  end
    
end
