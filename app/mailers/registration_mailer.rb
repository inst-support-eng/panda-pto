class RegistrationMailer < ApplicationMailer
    default from: 'blink.rankin@gmail.com'

    def registration_email
        @user = params[:user]
        @password = params[:password]
        mail(to: @user.email, subject: 'Your new Panda PTO account!')
    end
end
