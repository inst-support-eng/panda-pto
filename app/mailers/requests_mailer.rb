class RequestsMailer < ApplicationMailer
    default from: 'supportpanda@instructure.com'

    # email confirming request for pto was made 
    # see views/requests_email for email template
    # email triggered from pto_requests_controller
    def requests_email
        @user = params[:user]
        @pto_request = params[:pto_request]
        mail(to: @user.email, cc: "mco@instructure.com", subject: 'PTO Request')
    end

    def delete_request_email
        @user = params[:user]
        @pto_request = params[:pto_request]
        mail(to: @user.email, cc: "mco@instructure.com", subject: 'Deleted PTO Request')
    end    
    
    def day_of_request_email
        @user = params[:user]
        @pto_request = params[:pto_request]
        mail(to: @user.email, cc: "mco@instructure.com", subject: `Day of request for #{@user.name}`)
    end

    def two_day_out_request
        @user = params[:user]
        @pto_request = params[:pto_request]
        mail(to: @user.email, cc: "mco@instructure.com", subject: `Short notice request for #{@user.name}`)
    end
end
