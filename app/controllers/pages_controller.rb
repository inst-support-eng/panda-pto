###
# this controller is used in the calendar / sidebar views to determine quarters
###
class PagesController < ApplicationController
  before_action :login_required

  def index
    @user_requests = current_user.pto_requests.where(is_deleted: nil).or(current_user.pto_requests.where(is_deleted: 0))

    @current_quarter = Legalizer.quarter(Date.today)
    q1 = 0
    q2 = 0
    q3 = 0
    q4 = 0
    q1_next = 0
    q2_next = 0
    q3_next = 0
    q4_next = 0

    @bank_split = Legalizer.split_year(current_user)
    # calculate balance spent per quarter
    @user_requests.each do |r|
      if r.request_date.year == Date.today.year
        q = Legalizer.quarter(r.request_date)
        case q
        when 1
          q1 += r.cost
        when 2
          q2 += r.cost
        when 3
          q3 += r.cost
        when 4
          q4 += r.cost
        end
      elsif r.request_date.year == Date.today.year + 1
        q = Legalizer.quarter(r.request_date)
        case q
        when 1
          q1_next += r.cost
        when 2
          q2_next += r.cost
        when 3
          q3_next += r.cost
        when 4
          q4_next += r.cost
        end
      else
        next
      end
    end

    # calculate avalible balance for q1 of current year
    @q1_balance = if @bank_split[0] < (45 - q1)
                    @bank_split[0]
                  # a quarter's balence is 'negitive' when points from a later quarter are borrowed
                  # to complete a request. this is reflected in the borrowed quarter's balence, so
                  # should not be reflected as negive value in the borrower's quarter.
                  elsif (45 - q1) < 0
                    0
                  else
                    45 - q1
                  end
    # calculate avalible balance for q2 of current year
    @q2_balance = if @bank_split[0] < (90 - (q1 + q2))
                    @bank_split[0]
                  elsif (90 - (q1 + q2)) < 0
                    0
                  else
                    90 - (q1 + q2)
                  end
    # calculate avalible balance for q3 of current year
    @q3_balance = if @bank_split[0] < (135 - (q1 + q2 + q3))
                    @bank_split[0]
                  elsif (135 - (q1 + q2 + q3)) < 0
                    0
                  else
                    135 - (q1 + q2 + q3)
                  end
    # calculate avalible balance for q4 of current year
    @q4_balance = @bank_split[0]
    # account for large requests in future quarters
    # that 'barrow' from an earlier quarter
    @q3_balance = @q4_balance if @q3_balance > @q4_balance
    @q2_balance = @q3_balance if @q2_balance > @q3_balance
    @q1_balance = @q2_balance if @q1_balance > @q2_balance
    # calculate avalible balance for q1 of next year
    @q1_next_balance = if @bank_split[1] < (45 - q1_next)
                         @bank_split[0]
                       elsif 45 - q1_next < 0
                         0
                       else 
                        45 - q1_next
                       end
    # calculate avalible balance for q2 of next year
    @q2_next_balance = if @bank_split[1] < (90 - (q1_next + q2_next))
                         @bank_split[0]
                       elsif (90 - (q1_next + q2_next)) < 0
                        0
                       else
                         (90 - (q1_next + q2_next))
                       end
    # calculate avalible balance for q3 of next year
    @q3_next_balance = if @bank_split[1] < (135 - (q1_next + q2_next + q3_next))
                         @bank_split[0]
                       elsif (135 - (q1_next + q2_next + q3_next)) < 0
                         0
                       else
                        (135 - (q1_next + q2_next + q3_next))
                       end
    # calculate avalible balance for q4 of next year
    @q4_next_balence = @bank_split[1]
    # account for large requests in future quarters
    # that 'barrow' from an earlier quarter
    @q3_next_balence = @q4_next_balence if @q3_next_balance > @q4_next_balence
    @q2_next_balance = @q3_next_balance if @q2_next_balance > @q3_next_balance
    @q1_next_balance = @q2_next_balance if @q1_next_balance > @q2_next_balance
  end
end
