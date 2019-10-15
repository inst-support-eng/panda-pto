require 'rails_helper'

RSpec.describe CalendarsController, type: :controller do
  describe 'POST #import' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @calendar = FactoryBot.create(:calendar)
      sign_in(@user, scope: :user)
    end

    after(:each) do
      User.destroy_all
      Calendar.destroy_all
    end

    it 'should import calendar dates with prices' do
      @user.admin = true
      @user.save
      calendar_dates = [['2019-01-01', 0]]

      CSV.open('calendar.csv', 'w', col_sep: ',', headers: true) do |csv|
        csv << %w[date base_value]
        calendar_dates.each { |row| csv << row }
      end

      post :import, params: {
        file: fixture_file_upload('calendar.csv', 'text/csv')
      }

      expect(Calendar.count).to be(2)
      expect(Calendar.find_by(date: '2019-01-01').nil?).to be(false)
      expect(response).to redirect_to(admin_path)
      expect(:notice).to be_present
    end
  end

  describe 'POST #update_base_price' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @calendar = FactoryBot.create(:calendar)
      sign_in(@user, scope: :user)
    end

    after(:each) do
      User.destroy_all
      Calendar.destroy_all
    end

    it 'should update calendar price' do
      expect(@calendar.current_price).to eq(0.5)

      post :update_base_price, params: {
        date: { date: @calendar.date }, cost: { cost: 15 }
      }

      expect(@calendar.reload.current_price).to eq(1.5)
      expect(response).to redirect_to(admin_path)
    end
  end

  describe 'GET #fetch_dates' do
    it 'should render all calendar dates' do
      get :fetch_dates
      expect(response).to have_http_status(302)
    end
  end
end
