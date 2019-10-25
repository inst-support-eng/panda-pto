require 'rails_helper'

RSpec.describe RequestsMailer, type: :mailer do
  describe 'requests_email' do
    before(:each) do
      @user = FactoryBot.create(:user_with_one_request)
    end

    after(:each) do
      User.destroy_all
    end

    let(:mail) do
      RequestsMailer.with(user: @user,
                          pto_request: @user.pto_requests.first).requests_email
    end

    it 'renders the headers' do
      expect(mail.subject).to eq('PTO Request')
      expect(mail.to).to eq([@user.email])
      expect(mail.from).to eq([ENV['GMAIL_USERNAME']])
    end

    it 'renders the body' do
      expect(mail.body.encoded)
        .to include('This is to confirm that you’ve submitted PTO request')
    end
  end

  describe 'delete_request_email' do
    before(:each) do
      @user = FactoryBot.create(:user_with_one_request)
    end

    after(:each) do
      User.destroy_all
    end

    let(:mail) do
      RequestsMailer.with(user: @user,
                          pto_request: @user.pto_requests.first).delete_request_email
    end

    it 'renders the headers' do
      expect(mail.subject).to eq('Deleted PTO Request')
      expect(mail.to).to eq([@user.email])
      expect(mail.from).to eq([ENV['GMAIL_USERNAME']])
    end

    it 'renders the body' do
      expect(mail.body.encoded)
        .to include('This is to confirm that you’ve deleted a PTO request')
    end
  end

  describe 'admin_request_email' do
    before(:each) do
      @user = FactoryBot.create(:user_with_one_request)
      @sup = FactoryBot.create(:user, :supervisor)
    end

    after(:each) do
      User.destroy_all
    end

    let(:mail) do
      RequestsMailer.with(user: @user,
                          pto_request: @user.pto_requests.first,
                          supervisor: @sup).admin_request_email
    end

    it 'renders the headers' do
      expect(mail.to).to eq([@user.email])
      expect(mail.cc).to eq([ENV['MCO_EMAIL']])
      expect(mail.from).to eq([ENV['GMAIL_USERNAME']])
    end

    it 'renders the body' do
      expect(mail.body.encoded)
        .to include('This email is to confirm that a PTO deduction has been made on your behalf')
    end
  end

  describe 'excuse_request_email' do
    before(:each) do
      @user = FactoryBot.create(:user_with_one_request)
      @sup = FactoryBot.create(:user, :supervisor)
    end

    after(:each) do
      User.destroy_all
    end

    let(:mail) do
      RequestsMailer.with(user: @user,
                          pto_request: @user.pto_requests.first,
                          supervisor: @sup).excuse_request_email
    end

    it 'renders the headers' do
      expect(mail.to).to eq([@user.email])
      expect(mail.cc).to eq([ENV['MCO_EMAIL']])
      expect(mail.from).to eq([ENV['GMAIL_USERNAME']])
    end

    it 'renders the body' do
      expect(mail.body.encoded)
        .to include('This email is to confirm that a PTO adjustment has been made on your behalf')
    end
  end

  describe 'sick_make_up_email' do
    before(:each) do
      @user = FactoryBot.create(:user_with_one_request)
    end

    after(:each) do
      User.destroy_all
    end

    let(:mail) do
      RequestsMailer.with(user: @user,
                          pto_request: @user.pto_requests.first).sick_make_up_email
    end

    it 'renders the headers' do
      expect(mail.to).to eq([@user.email])
      expect(mail.cc).to eq([ENV['MCO_EMAIL']])
      expect(mail.from).to eq([ENV['GMAIL_USERNAME']])
    end

    it 'renders the body' do
      expect(mail.body.encoded)
        .to include('You were out of the office on')
    end
  end

  describe 'no_call_show_email' do
    before(:each) do
      @user = FactoryBot.create(:user_with_one_request)
    end

    after(:each) do
      User.destroy_all
    end

    let(:mail) do
      RequestsMailer.with(user: @user,
                          pto_request: @user.pto_requests.first).sick_make_up_email
    end

    it 'renders the headers' do
      expect(mail.to).to eq([@user.email])
      expect(mail.cc).to eq([ENV['MCO_EMAIL']])
      expect(mail.from).to eq([ENV['GMAIL_USERNAME']])
    end

    it 'renders the body' do
      expect(mail.body.encoded)
        .to include('You were out of the office on')
    end
  end
end
