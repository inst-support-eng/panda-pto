require 'rails_helper'

RSpec.describe CoverageMailer, type: :mailer do
  describe 'Coverage mailer' do
    before(:each) do
      @calendar = FactoryBot.create(:calendar, :calendar_today)
    end

    after(:each) do
      Calendar.destroy_all
    end

    let(:mail) { CoverageMailer.off_today }

    it 'renders the headers' do
      expect(mail.subject).to include('Agents off today:')
      expect(mail.to).to eq([ENV['MCO_EMAIL']])
      expect(mail.from).to eq([ENV['GMAIL_USERNAME']])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include('No agents are schedlued off today')
    end
  end
end
