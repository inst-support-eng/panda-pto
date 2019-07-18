class CoverageMailer < ApplicationMailer
  default from: ENV['APP_FROM_EMAIL']

  def off_today
    mail(to: ENV['MCO_EMAIL'], subject: "Agents off today: #{Date.today.strftime("%A, %Y-%m-%d")}")
  end
end
