class RegistrationMailer < ApplicationMailer
    default from: ENV['APP_FROM_EMAIL']

    def registration_email
        @user = params[:user]
        @password = params[:password]
        mail(to: @user.email, subject: 'Your new Panda PTO account!')
    end

    def new_employee_email
        @user = params[:user]
        mail(to: @user.email, subject: 'Panda PTO information')
    end

end
