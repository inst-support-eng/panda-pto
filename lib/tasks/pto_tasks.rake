desc "send list of agents off for the current day to MCO"
task :coverage_mailer => :environment do
  # @today = Calendar.find_by(:date => Date.today)
  CoverageMailer.off_today.deliver_now
end

desc "Seed user accounts with 45 points at the begining of each quarter"
task :quarterly_seed => :environment do
  quarters = ['-01-01', '-04-01', '-07-01', '-10-01']
  if quarters.any? { |date| Date.today.to_s.include?(date) } 
    User.find_each do |agent|
      if agent.bank_value >= 135
        agent.bank_value = 180
      else 
        agent.bank_value += 45
      end
      agent.save
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
