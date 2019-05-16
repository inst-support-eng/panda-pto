class CoverageMailer < ApplicationMailer
  default from: 'supportpanda@instructure.com'

  def off_today
    mail(to: ENV['MCO_EMAIL'], subject: "Agents off today: #{Date.today.strftime("%A, %Y-%m-%d")}")
  end
end
