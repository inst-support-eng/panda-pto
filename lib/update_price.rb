class UpdatePrice
  def self.update_calendar_item(date)
    # these hashes map how a Calendar object's signed_up_total & base_value sum to the per-hour price for PtoRequests
    scale = { 0  => 0.5, 8  => 1, 15 => 1.5, 21 => 2, 26 => 2.5, 30 => 3, 33 => 3.5, 35 => 4, 36 => 5, 37 => 6, 38 => 7, 39 => 8, 40 => 9 }
    weekend_scale = { 0  => 0.5, 4  => 1, 7 => 1.5, 9 => 2, 10 => 2.5, 11 => 3, 12 => 3.5, 13 => 4, 14 => 5, 15 => 6, 16 => 7, 17 => 8, 18 => 9 }
    
    # validate input, this method can be accept:
    # a) Date object b) iso-8601 formatted string c) Calendar object
    # ! it is prefered a Calendar object is passed
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

    # weekend scaling
    if @calendar.date.wday == 0 || @calendar.date.wday == 6
      case @updated
      when weekend_scale.keys[0]..(weekend_scale.keys[1] - 1)
        @calendar.current_price = weekend_scale.values[0]
      when weekend_scale.keys[1]..(weekend_scale.keys[2] - 1)
        @calendar.current_price = weekend_scale.values[1]
      when weekend_scale.keys[2]..(weekend_scale.keys[3] - 1)
        @calendar.current_price = weekend_scale.values[2]
      when weekend_scale.keys[3]..(weekend_scale.keys[4] - 1)
        @calendar.current_price = weekend_scale.values[3]
      when weekend_scale.keys[4]..(weekend_scale.keys[5] - 1)
        @calendar.current_price = weekend_scale.values[4]
      when weekend_scale.keys[5]..(weekend_scale.keys[6] - 1)
        @calendar.current_price = weekend_scale.values[5]
      when weekend_scale.keys[6]..(weekend_scale.keys[7] - 1)
        @calendar.current_price = weekend_scale.values[6]
      when weekend_scale.keys[7]..(weekend_scale.keys[8] - 1)
        @calendar.current_price = weekend_scale.values[7]
      when weekend_scale.keys[8]..(weekend_scale.keys[9] - 1)
        @calendar.current_price = weekend_scale.values[8]
      when weekend_scale.keys[9]..(weekend_scale.keys[10] - 1)
        @calendar.current_price = weekend_scale.values[9]
      when weekend_scale.keys[10]..(weekend_scale.keys[11] - 1)
        @calendar.current_price = weekend_scale.values[10]
      when weekend_scale.keys[11]..(weekend_scale.keys[12] - 1)
        @calendar.current_price = weekend_scale.values[11]
      when weekend_scale.keys[12]..1000
        @calendar.current_price = weekend_scale.values[12]
      else
        raise "something went wrong"
      end
    # week day scaling
    else
      case @updated
      when scale.keys[0]..(scale.keys[1] - 1)
        @calendar.current_price = scale.values[0]
      when scale.keys[1]..(scale.keys[2] - 1)
        @calendar.current_price = scale.values[1]
      when scale.keys[2]..(scale.keys[3] - 1)
        @calendar.current_price = scale.values[2]
      when scale.keys[3]..(scale.keys[4] - 1)
        @calendar.current_price = scale.values[3]
      when scale.keys[4]..(scale.keys[5] - 1)
        @calendar.current_price = scale.values[4]
      when scale.keys[5]..(scale.keys[6] - 1)
        @calendar.current_price = scale.values[5]
      when scale.keys[6]..(scale.keys[7] - 1)
        @calendar.current_price = scale.values[6]
      when scale.keys[7]..(scale.keys[8] - 1)
        @calendar.current_price = scale.values[7]
      when scale.keys[8]..(scale.keys[9] - 1)
        @calendar.current_price = scale.values[8]
      when scale.keys[9]..(scale.keys[10] - 1)
        @calendar.current_price = scale.values[9]
      when scale.keys[10]..(scale.keys[11] - 1)
        @calendar.current_price = scale.values[10]
      when scale.keys[11]..(scale.keys[12] - 1)
        @calendar.current_price = scale.values[11]
      when scale.keys[12]..1000
        @calendar.current_price = scale.values[12]
      else
        raise "something went wrong"
      end
    end
    @calendar.save
  end
end 
