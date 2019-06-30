class Legalizer


  def self.split_year(user)

    # determine how many points agent spent on pto for the next calendar year
    next_year = (Date.today.year + 1).to_s
    next_year_requests = user.pto_requests.where('extract(year from request_date) = ?', next_year).to_a
    
    next_year_total = 0
    
    next_year_requests.each do |r|
      next_year_total += r.cost
    end

    # determine today's quarter , adapted from pages_controller.rb
    current_year = Date.today.year
    date = Date.today
    current_quarter = 0
    current_year
    quarters = [Date.parse("#{current_year}-01-01"), Date.parse("#{current_year}-04-01"), Date.parse("#{current_year}-07-01"), Date.parse("#{current_year}-10-01")]
    if date < quarters[0]
      current_quarter = 1
    elsif date < quarters[1]
      current_quarter = 2
    elsif date < quarters[2]
      current_quarter = 3
    elsif date > quarters[3]
      current_quarter = 4
    else 
      return nil
    end


    current_year_balence = 0
    next_year_balenence = 0

    # seperate points
    case current_quarter
    when 1
      current_year_balence = user.bank_value
    when 2
      current_year_balence = user.bank_value - 45
      next_year_balenence = 45 - next_year_total
    when 3
      current_year_balence = user.bank_value - 90
      next_year_balenence = 90 - next_year_total
    when 4
      current_year_balence = user.bank_value - 135
      next_year_balenence = 135 - next_year_total
    else
    end

    return current_year_balence, next_year_balenence
  end

end