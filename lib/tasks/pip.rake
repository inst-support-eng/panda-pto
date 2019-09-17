desc "remove new hires from 90 day pip"
task :new_hire_check_pip => :environment do
    @users = User.all

    @users.each do |user|
        if user.start_date == Date.today - 3.months && user.on_pip == true
            user.on_pip = false
            user.save
        end
    end
end