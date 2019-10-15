require 'rails_helper'
require 'spec_helper'
require 'rake'

describe 'update new hires pip status' do
  let (:run_rake_task) do
    Rake.application.invoke_task 'new_hire_check_pip'
  end

  before do
    Rake.application.rake_require 'tasks/pip'
    Rake::Task.define_task(:environment)
  end

  before(:each) do
    @new_hire = FactoryBot.create(:user, :new_hire)
    @user_on_pip = FactoryBot.create(:user, :on_pip_user)
  end

  after(:each) do
    User.destroy_all
  end

  describe 'check new hires on_pip' do
    it 'should update new hires on_pip to eq false' do
      run_rake_task

      expect(@new_hire.reload.on_pip).to eq(false)
    end

		it 'should not update users on_pop w/ start_date 3.months' do
			run_rake_task

			expect(@user_on_pip.reload.on_pip).to eq(true)
    end
  end
end
