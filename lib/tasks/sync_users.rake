desc "get and sync users from humanity"
task :sync_users => :environment do
    humanity_users = HumanityAPI.get_employees

    humanity_users.each do |u|
        agent = User.find_by(:email => u['email'])
        if agent.nil?
            puts `no agent with the email #{u['email']}`
        else 
            agent.name = u['name']
        end
    end
end
