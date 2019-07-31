class UpdatePrice
  def self.update_calendar_item(date)    
    # validate input, this method can be accept:
    # a) Date object b) iso-8601 formatted string c) Calendar object
    # ! it is prefered a Calendar object is passed
    # doesn't return anything, only updateds the passed Calendar object
    if date.is_a? Date or date.is_a? String
      @calendar = Calendar.find_by(:date => date)
    elsif
      @calendar = date
    end
    
    # find the sum of signed_up_total & base_value
    # don't do math with nil values
    if @calendar.signed_up_total == nil
      @updated = @calendar.base_value
    else
      @updated = @calendar.base_value + @calendar.signed_up_total
    end

    @calendar.current_price = value_map(@updated, @calendar.date)
    @calendar.save 
  end

  def self.update_pto_requests(request)
    # accepts an array of PtoRequests, updates the object and
    # refunds the associated user bank_value if
    # 
    return "something went wrong!" if request.class != Array

    request.each do |r|
      shift_length = 8
      shift_length = 10 if r.user.ten_hour_shift? 

      reduced_price = value_map((r.signed_up_total - 1), r.request_date)
      cost_difference = r.cost - (reduced_price * shift_length)
      if cost_difference > 0
        r.user.bank_value += cost_difference
        r.user.save
        r.cost -= cost_difference
        r.save
      else
        next
      end

    end
  end

  def self.value_map(input, date)
    # accepts a integer and date
    # the integer should be equal to signed_up_total + base_value
    # returns a per hour value 

    # these hashes map how a Calendar object's signed_up_total & base_value sum to the per-hour price for PtoRequests
    scale = { 0  => 0.5, 8  => 1, 15 => 1.5, 21 => 2, 26 => 2.5, 30 => 3, 33 => 3.5, 35 => 4, 36 => 5, 37 => 6, 38 => 7, 39 => 8, 40 => 9 }
    weekend_scale = { 0  => 0.5, 4  => 1, 7 => 1.5, 9 => 2, 10 => 2.5, 11 => 3, 12 => 3.5, 13 => 4, 14 => 5, 15 => 6, 16 => 7, 17 => 8, 18 => 9 }
    output = -1

    date = Date.parse(date) unless date.is_a? Date

    # weekend scaling
    if date.wday == 0 || date.wday == 6
      case input
      when weekend_scale.keys[0]..(weekend_scale.keys[1] - 1)
        output = weekend_scale.values[0]
      when weekend_scale.keys[1]..(weekend_scale.keys[2] - 1)
        output = weekend_scale.values[1]
      when weekend_scale.keys[2]..(weekend_scale.keys[3] - 1)
        output = weekend_scale.values[2]
      when weekend_scale.keys[3]..(weekend_scale.keys[4] - 1)
        output = weekend_scale.values[3]
      when weekend_scale.keys[4]..(weekend_scale.keys[5] - 1)
        output = weekend_scale.values[4]
      when weekend_scale.keys[5]..(weekend_scale.keys[6] - 1)
        output = weekend_scale.values[5]
      when weekend_scale.keys[6]..(weekend_scale.keys[7] - 1)
        output = weekend_scale.values[6]
      when weekend_scale.keys[7]..(weekend_scale.keys[8] - 1)
        output = weekend_scale.values[7]
      when weekend_scale.keys[8]..(weekend_scale.keys[9] - 1)
        output = weekend_scale.values[8]
      when weekend_scale.keys[9]..(weekend_scale.keys[10] - 1)
        output = weekend_scale.values[9]
      when weekend_scale.keys[10]..(weekend_scale.keys[11] - 1)
        output = weekend_scale.values[10]
      when weekend_scale.keys[11]..(weekend_scale.keys[12] - 1)
        output = weekend_scale.values[11]
      when weekend_scale.keys[12]..1000
        output = weekend_scale.values[12]
      else
        raise "something went wrong"
      end
      # week day scaling
    else
      case input
      when scale.keys[0]..(scale.keys[1] - 1)
        output = scale.values[0]
      when scale.keys[1]..(scale.keys[2] - 1)
        output = scale.values[1]
      when scale.keys[2]..(scale.keys[3] - 1)
        output = scale.values[2]
      when scale.keys[3]..(scale.keys[4] - 1)
        output = scale.values[3]
      when scale.keys[4]..(scale.keys[5] - 1)
        output = scale.values[4]
      when scale.keys[5]..(scale.keys[6] - 1)
        output = scale.values[5]
      when scale.keys[6]..(scale.keys[7] - 1)
        output = scale.values[6]
      when scale.keys[7]..(scale.keys[8] - 1)
        output = scale.values[7]
      when scale.keys[8]..(scale.keys[9] - 1)
        output = scale.values[8]
      when scale.keys[9]..(scale.keys[10] - 1)
        output = scale.values[9]
      when scale.keys[10]..(scale.keys[11] - 1)
        output = scale.values[10]
      when scale.keys[11]..(scale.keys[12] - 1)
        output = scale.values[11]
      when scale.keys[12]..1000
        output = scale.values[12]
      else
        raise "something went wrong"
      end
      
      return output
    end
  end


end