# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def seed_users
    User.create({ name: "test", email: "test@test.com", bank_value: "2000", password: 'password1', password_confirmation: 'password1'})
end

def seed_calendar
    Calendar.create(date: "2019-10-01", base_value: 0, signed_up_total: 0, signed_up_agents: [], current_price: 0)

    day = 1;
    month = 1;

    12.times do 
        if month < 10 
            smonth = '0' + month.to_s
        else 
            smonth = month.to_s
        end

        31.times do 
            if day < 10 
                sday = '0'+ day.to_s
            else 
                sday = day.to_s
            end 
            Calendar.create({ date: '2019-#{month}-#{day}', base_value: 0, signed_up_total: 0, signed_up_agents: [], current_price: 0})
            day += 1
            month += 1
        end
    end

end

seed_users
seed_calendar