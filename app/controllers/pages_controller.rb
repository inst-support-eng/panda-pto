class PagesController < ApplicationController
    before_action :login_required

    def index
        @current_quarter = Legalizer.quarter(Date.today)
        @q1 = 0
        @q2 = 0
        @q3 = 0
        @q4 = 0
        @q1_next = 0
        @q2_next = 0
        @q3_next = 0

        @bank_split = Legalizer.split_year(current_user)
        
        current_user.pto_requests.each do |r|
            if r.request_date.year == Date.today.year
                q = Legalizer.quarter(r.request_date)
                case q
                when 1
                    @q1 += r.cost
                when 2
                    @q2 += r.cost
                when 3
                    @q3 += r.cost
                when 4
                    @q4 += r.cost
                end
            elsif r.request_date.year == Date.today.year + 1
                q = Legalizer.quarter(r.request_date)
                case q
                when 1
                    @q1_next += r.cost
                when 2
                    @q2_next += r.cost
                when 3
                    @q3_next += r.cost
                end 
            else
                next
            end
        end

    end

end
