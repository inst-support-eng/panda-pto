##
# soft_deletes users from db/ ui so they can be restored later
# and appear in reporting
##
class SoftDelete
  def self.delete_future_requesets(user)
    user_future_requests = user.pto_requests.where('request_date > ?', Date.today).to_a
    user_future_requests.each do |r|
      user.bank_value += r.cost

      if r.reason == 'no call / no show'
        unless user.no_call_show.nil? || user.no_call_show.zero?
          user.no_call_show -= 1
        end
      elsif r.reason == 'make up / sick day'
        unless user.make_up_days.nil? || user.make_up_days.zero?
          user.make_up_days -= 1
        end
      end

      future_requests = PtoRequest.where(['request_date = ? and created_at > ?', r.request_date, r.created_at]).to_a
      if future_requests.count.positive?
        UpdatePrice.update_pto_requests(future_requests)
      end

      calendar = Calendar.find_by(date: r.request_date)
      calendar.signed_up_agents.delete(user.name)
      calendar.signed_up_total >= 1 ? calendar.signed_up_total -= 1 : calendar.signed_up_total = 0
      calendar.save
      UpdatePrice.update_calendar_item(calendar)
      HumanityAPI.delete_request(r.humanity_request_id)
      r.update(is_deleted: 1)
    end
    user.save
  end
end
