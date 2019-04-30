class RequestsMailer < ApplicationMailer
    default from: 'supportpanda@instructure.com'

    before_action :get_params, only: %i[requests_email delete_request_email admin_request_email excuse_request_email sick_make_up_email zero_credit_email missed_holiday_email no_call_show_email]

    # email confirming request for pto was made 
    # see views/requests_email for email template
    # email triggered from pto_requests_controller
    def requests_email
        mail(to: @user.email, cc: "mco@instructure.com", subject: 'PTO Request')
    end

    def delete_request_email
        mail(to: @user.email, cc: "mco@instructure.com", subject: 'Deleted PTO Request')
    end    
    
    def admin_request_email
        @supervisor = params[:supervisor]
        mail(to: @user.email, cc: "mco@instructure.com", subject: `Admin request for #{@user.name}`)
    end

    def excuse_request_email
        @supervisor = params[:supervisor]
        mail(to: @user.email, cc: "mco@instructure.com", subject: `Excused request for #{@user.name}`)
    end

    def sick_make_up_email
        mail(to: @user.email, cc: "mco@instrucure.com", subject: `Sick day for #{@user.name}`)
    end

    def zero_credit_email
        @user = params[:user]
        @pto_request = parmas[:pto_request]
        mail(to: @user.email, cc:"mco@instructure.com", subject: `PTO Credits Have reached Zero`)
    end

    ## TALK TO TDYE / LBURNETT 
    def missed_holiday_email
        mail(to: @user.email, cc:"mco@instructure.com", subject: `Missed Holiday for `)
    end

    def no_call_show_email

    end

    def eight_credits_email
        @user = params[:user]
        mail(to: @user.email, cc:"mco@instructure.com", subject: `#{user.bank_value} PTO Credits Remain `)
    end

    def credits_vested_email
        @user = params[:user]
        mail(to: @user.email, subject: "PTO Credits have been added to your account")
    end

    def make_up_day_email
    end

    def missed_day_training_group
    end

    def missed_more_that_one_training_day_email
    end

    def end_of_year_email
    end

    private

    def get_params
        @user = params[:user]
        @pto_request = params[:pto_request]
    end
end
