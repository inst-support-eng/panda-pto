desc 'check for long requests'
task check_long_requests: :environment do
  requests = PtoRequest.where('created_at > ?', Date.yesterday)
  long_request_users = []
  seen_requests = []

  requests.each do |r|
    user = User.find(r.user_id)
    user_requests = user.pto_requests.where('request_date > ?', Date.today)
    consecutive_requests = [r]

    check_for_long_request(user_requests, r, seen_requests, consecutive_requests)
    if requests.count >= 4 && long_request_users.exclude?(user.name)
      long_request_users.push(user.name)
    end
  end

  unless long_request_users.empty?
    RequestsMailer.with(users: long_request_users).long_requests_email.deliver_now
  end
end

def check_for_long_request(user_requests, req, seen_requests, consecutive_requests)
  return if seen_requests.include?(req)

  prev_request = user_requests.find_by(request_date: req.request_date - 1.day)
  next_request = user_requests.find_by(request_date: req.request_date + 1.day)

  return if prev_request.nil?
  return if next_request.nil?

  seen_requests.push(req)

  unless prev_request.nil?
    consecutive_requests.push(prev_request)
    return check_for_long_request(user_requests, prev_request, seen_requests, consecutive_requests)
  end

  unless next_request.nil?
    consecutive_requests.push(next_request)
    return check_for_long_request(user_requests, next_request, seen_requests, consecutive_requests)
  end
end
