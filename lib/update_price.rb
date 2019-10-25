##
# updates calendar price dependants on data and the num of signed up agents
##

class UpdatePrice
  def self.update_calendar_item(date)
    # validate input, this method can be accept:
    # a) Date object b) iso-8601 formatted string c) Calendar object
    # ! it is prefered a Calendar object is passed
    # doesn't return anything, only updateds the passed Calendar object
    if date.is_a?(Date) || date.is_a?(String)
      @calendar = Calendar.find_by(date: date)
    elsif
      @calendar = date
    end

    # find the sum of signed_up_total & base_value
    # don't do math with nil values
    @updated = if @calendar.signed_up_total.nil?
                 @calendar.base_value
               else
                 @calendar.base_value + @calendar.signed_up_total
               end
    @calendar.current_price = value_map(@updated, @calendar.date)
    @calendar.save
  end

  def self.update_pto_requests(request)
    # accepts an array of PtoRequests, updates the object and
    # refunds the associated user bank_value if request would
    # have cost less than what was originally paid
    return 'something went wrong!' if request.class != Array

    request.each do |r|
      next if r.signed_up_total.nil?

      shift_length = 8
      shift_length = 10 if r.user.ten_hour_shift?
      reduced_total = r.signed_up_total - 1
      reduced_total = 0 if reduced_total.negative?
      cal = Calendar.find_by(date: r.request_date)

      reduced_price = value_map((reduced_total + cal.base_value), r.request_date)
      cost_difference = r.cost - (reduced_price * shift_length)
      if cost_difference.positive?
        r.user.bank_value += cost_difference
        r.user.save
        r.cost -= cost_difference
        r.signed_up_total -= 1
        r.save
      else
        r.signed_up_total -= 1
        r.save
        next
      end
    end
  end

  def self.value_map(input, date)
    # accepts a integer and date
    # the integer should be equal to signed_up_total + base_value
    # returns a per hour value

    # these hashes map how a Calendar object's signed_up_total & base_value sum to the per-hour price for PtoRequests
    scale = { 0 => 0.5, 8 => 1, 15 => 1.5, 21 => 2, 26 => 2.5, 30 => 3, 33 => 3.5, 35 => 4, 36 => 5, 37 => 6, 38 => 7, 39 => 8, 40 => 9 }
    weekend_scale = { 0 => 0.5, 4 => 1, 7 => 1.5, 9 => 2, 10 => 2.5, 11 => 3, 12 => 3.5, 13 => 4, 14 => 5, 15 => 6, 16 => 7, 17 => 8, 18 => 9 }

    date = Date.parse(date) unless date.is_a? Date

    # weekend scaling
    if date.wday == 0 || date.wday == 6
      case input
      when weekend_scale.keys[0]..(weekend_scale.keys[1] - 1)
        return weekend_scale.values[0]
      when weekend_scale.keys[1]..(weekend_scale.keys[2] - 1)
        return weekend_scale.values[1]
      when weekend_scale.keys[2]..(weekend_scale.keys[3] - 1)
        return weekend_scale.values[2]
      when weekend_scale.keys[3]..(weekend_scale.keys[4] - 1)
        return weekend_scale.values[3]
      when weekend_scale.keys[4]..(weekend_scale.keys[5] - 1)
        return weekend_scale.values[4]
      when weekend_scale.keys[5]..(weekend_scale.keys[6] - 1)
        return weekend_scale.values[5]
      when weekend_scale.keys[6]..(weekend_scale.keys[7] - 1)
        return weekend_scale.values[6]
      when weekend_scale.keys[7]..(weekend_scale.keys[8] - 1)
        return weekend_scale.values[7]
      when weekend_scale.keys[8]..(weekend_scale.keys[9] - 1)
        return weekend_scale.values[8]
      when weekend_scale.keys[9]..(weekend_scale.keys[10] - 1)
        return weekend_scale.values[9]
      when weekend_scale.keys[10]..(weekend_scale.keys[11] - 1)
        return weekend_scale.values[10]
      when weekend_scale.keys[11]..(weekend_scale.keys[12] - 1)
        return weekend_scale.values[11]
      when weekend_scale.keys[12]..1000
        return weekend_scale.values[12]
      else
        raise 'something went wrong'
      end
      # week day scaling
    else
      case input
      when scale.keys[0]..(scale.keys[1] - 1)
        return scale.values[0]
      when scale.keys[1]..(scale.keys[2] - 1)
        return scale.values[1]
      when scale.keys[2]..(scale.keys[3] - 1)
        return scale.values[2]
      when scale.keys[3]..(scale.keys[4] - 1)
        return scale.values[3]
      when scale.keys[4]..(scale.keys[5] - 1)
        return scale.values[4]
      when scale.keys[5]..(scale.keys[6] - 1)
        return scale.values[5]
      when scale.keys[6]..(scale.keys[7] - 1)
        return scale.values[6]
      when scale.keys[7]..(scale.keys[8] - 1)
        return scale.values[7]
      when scale.keys[8]..(scale.keys[9] - 1)
        return scale.values[8]
      when scale.keys[9]..(scale.keys[10] - 1)
        return scale.values[9]
      when scale.keys[10]..(scale.keys[11] - 1)
        return scale.values[10]
      when scale.keys[11]..(scale.keys[12] - 1)
        return scale.values[11]
      when scale.keys[12]..1000
        return scale.values[12]
      else
        raise 'something went wrong'
      end
    end
  end
end
