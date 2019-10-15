## checks new hires date and removes on_pip status
class NewHireCheck
  def self.update_on_pip
    date_check = (Date.today - 3.months)
    users_on_pip = User
                   .where(start_date: date_check.beginning_of_day..date_check.end_of_day)
                   .where(on_pip: true)

    users_on_pip.update_all(on_pip: false)
  end
end
