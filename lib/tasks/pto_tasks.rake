desc "send list of agents off for the current day to MCO"
task :coverage_mailer => :environment do
  # @today = Calendar.find_by(:date => Date.today)
  CoverageMailer.off_today.deliver_now
end

desc "Seed user accounts with 45 points at the begining of each quarter"
task :quarterly_seed => :environment do
  quarters = ['-04-01', '-07-01', '-10-01']
  year_start = '-01-01'
  if Date.today.to_s.include?(year_start)
    User.find_each do |agent|
      requests = agent.pto_requests.where('extract(year from request_date) = ?', Date.today.year).to_a
      year_total = 0
      requests.each do |r|
        year_total += r.cost
      end
      agent.bank_value = 180 - year_total
      agent.save
    end
  elsif quarters.any? { |date| Date.today.to_s.include?(date) } 
    User.find_each do |agent|
      if agent.bank_value >= 270
        agent.bank_value = 315
      else 
        agent.bank_value += 45
      end
      agent.save
      # RequestsMailer.with(:user => agent).credits_added_email.deliver_now
    end
  else
    exit
  end
end

desc "Import agents.csv from google sheet defined in the enviorment"
task :sync_agents => :environment do
  csv = GoogleAPI.get_csv(ENV['AGENT_MASTER_SHEET'], "A1:I")
  User.import(csv)
  csv.close(unlink=true)
end