class RegistrationMailer < ApplicationMailer
    default from: 'cmerchant@instructure.com'

    def registration_email
        @user = params[:user]
        @password = params[:password]
        mail(to: @user.email, subject: 'Your new Panda PTO account!')
    end
end
