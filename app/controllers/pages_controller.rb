class PagesController < ApplicationController
    before_action :login_required

    def quarter(date)
        date = Date.parse(date) if date.is_a? String
        quarters = [Date.parse("#{date.year}-01-01"), Date.parse("#{date.year}-04-01"), Date.parse("#{date.year}-07-01"), Date.parse("#{date.year}-10-01")]
        if date < quarters[1]
            return 1
        elsif date < quarters[2]
            return 2
        elsif date < quarters[3]
            return 3
        elsif date > quarters[3]
            return 4
        else 
            return nil
        end
    end

    def index
        @current_quarter = quarter(Date.today)
        @q1 = 0
        @q2 = 0
        @q3 = 0
        @q4 = 0
        @q1_next = 0
        @q2_next = 0
        @q3_next = 0
        
        current_user.pto_requests.each do |r|
            if r.request_date.year == Date.today.year
                q = quarter(r.request_date)
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
            elsif r.request_date.year == Data.today.year + 1
                q = quarter(r.request_date)
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
