###
# Class used to determine quarters for vestings and when / how PTO can be taken  
###
class Legalizer
  def self.quarter(date)
    date = Date.parse(date) if date.is_a? String
    quarters = [Date.parse("#{date.year}-01-01"), Date.parse("#{date.year}-04-01"), Date.parse("#{date.year}-07-01"), Date.parse("#{date.year}-10-01")]
    if date < quarters[1]
        return 1
    elsif date < quarters[2]
        return 2
    elsif date < quarters[3]
        return 3
    elsif date >= quarters[3]
        return 4
    else 
        return nil
    end
  end

  def self.split_year(user)
    # determine how many points agent spent on pto for the next calendar year
    next_year = (Date.today.year + 1).to_s
    next_year_requests = user.pto_requests.where('extract(year from request_date) = ?', next_year).to_a
    this_year_requests = user.pto_requests.where('extract(year from request_date) = ?', Date.today.year.to_s).to_a
    
    this_year_total = 0
    next_year_total = 0
    
    this_year_requests.each do |r|
      if r.is_deleted != true
        this_year_total += r.cost
      end
    end

    next_year_requests.each do |r|
      if r.is_deleted != true
        next_year_total += r.cost
      end
    end

    # determine today's quarter , adapted from pages_controller.rb
    current_year = Date.today.year
    date = Date.today
    current_quarter = quarter(date)

    if user.start_date.year == date.year
      current_year_balance = user.bank_value - (((current_quarter * 45) - 45) + next_year_total)
    else
      current_year_balance = 180 - this_year_total
    end

    next_year_balance = 0

    # seperate points
    case current_quarter
    when 1
    when 2
      next_year_balance = 45 - next_year_total
    when 3
      next_year_balance = 90 - next_year_total
    when 4
      next_year_balance = 135 - next_year_total
    else
    end

    return current_year_balance, next_year_balance
  end
end
