module UpdatePriceHelper

  def update_price(date, slots)
    value_map = { 0  => 0.5, 7  => 1, 13 => 1.5, 18 => 2, 22 => 2.5, 25 => 3, 27 => 3.5, 28 => 4, 29 => 5, 30 => 6, 31 => 7, 32 => 8, 33 => 9 }
    @calendar = Calendar.find_by(:date => date)
    @calendar.base_value = slots
    
    case slots
    when value_map.keys[0]..value_map.keys[1]
      @calendar.current_price = value_map.values[0]
    when value_map.keys[1]..value_map.keys[2]
      @calendar.current_price = value_map.values[2]
    when value_map.keys[2]..value_map.keys[3]
      @calendar.current_price = value_map.values[2]
    when value_map.keys[3]..value_map.keys[4]
      @calendar.current_price = value_map.values[3]
    when value_map.keys[4]..value_map.keys[5]
      @calendar.current_price = value_map.values[4]
    when value_map.keys[5]..value_map.keys[6]
      @calendar.current_price = value_map.values[5]
    when value_map.keys[6]..value_map.keys[7]
      @calendar.current_price = value_map.values[6]
    when value_map.keys[7]..value_map.keys[8]
      @calendar.current_price = value_map.values[7]
    when value_map.keys[8]..value_map.keys[9]
      @calendar.current_price = value_map.values[8]
    when value_map.keys[9]..value_map.keys[10]
      @calendar.current_price = value_map.values[9]
    when value_map.keys[10]..value_map.keys[11]
      @calendar.current_price = value_map.values[10]
    when value_map.keys[11]..value_map.keys[12]
      @calendar.current_price = value_map.values[11]
    when value_map.keys[12]..1000
      @calendar.current_price = value_map.values[12]
    else
      raise "something went wrong"
    end
    @calendar.save
  end
end
