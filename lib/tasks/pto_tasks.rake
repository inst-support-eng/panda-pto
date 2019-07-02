desc "send list of agents off for the current day to MCO"
task :coverage_mailer => :environment do
  # @today = Calendar.find_by(:date => Date.today)
  CoverageMailer.off_today.deliver_now
end

desc "Seed user accounts with 45 points at the begining of each quarter"
task :quarterly_seed => :environment do
  quarters = ['-04-01', '-07-02', '-10-01']
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

task :data_fix_07_02 => :environment do
  affected_users = [167, 169, 17, 4, 29, 42, 55, 58, 1, 65, 72, 83, 81, 82, 92, 46, 110, 117, 56, 68, 66, 153, 154, 159, 100, 101, 112, 119, 134, 151, 135, 144, 148, 132, 136, 157, 59, 106, 49, 124]
  affected_users.each do |x|
    agent = User.find(x)
    requests = agent.pto_requests.where('extract(year from request_date) = ?', Date.today.year).to_a
    year_total = 0
    requests.each do |r|
      year_total += r.cost
    end
    agent.bank_value = 180 - year_total + 90
    agent.save
  end
end