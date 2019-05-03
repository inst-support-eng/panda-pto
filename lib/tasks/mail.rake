desc "send daily coverage mailer"
task :coverage_mailer => :environment do
  # @today = Calendar.find_by(:date => Date.today)
  CoverageMailer.off_today.deliver_now
end