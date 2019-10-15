require 'rails_helper'
require 'spec_helper'
require 'rake'

describe 'update new hires pip status' do
  let(:run_rake_task) do
    Rake.application.invoke_task 'coverage_mailer'
  end

  before do
    Rake.application.rake_require 'tasks/pto_tasks'
    Rake::Task.define_task(:environment)
  end

  before(:each) do
    @calendar = FactoryBot.create(:calendar, :calendar_today)
  end

  after(:each) do
    Calendar.destroy_all
  end

  describe 'should send night mailer' do
    it 'should increase the queue by 1' do
      run_rake_task

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end
end
