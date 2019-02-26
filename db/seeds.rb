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
end

seed_users
seed_calendar