# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PtoRequestsController, type: :controller do
  describe 'GET #export' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @calendar = FactoryBot.create(:calendar)
      @pto_request = { user_id: @user.id, reason: 'disneyland',
                       request_date: 10.days.from_now, cost: 10 }
      sign_in(@user, scope: :user)
      get :export, format: :csv
    end
    after(:each) do
      User.delete_all
      PtoRequest.delete_all
      Calendar.delete_all
    end

    it 'should export a csv of all requests' do
      expect(response.header['Content-Type']).to include('application/octet-stream')
      expect(response.status).to eq(200)
    end
  end

  describe 'POST #import_request' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @calendar = FactoryBot.create(:calendar)
      sign_in(@user, scope: :user)
    end

    it 'should import and create requests' do
      requests = [[@calendar.date, @user.email, 8]]

      @user.admin = true
      @user.reload

      CSV.open('test.csv', 'w', col_sep: ',', headers: true) do |csv|
        csv << %w[date email shift]
        requests.each { |row| csv << row }
      end

      post :import_request, params: { file: fixture_file_upload('test.csv', 'text/csv') }

      expect(PtoRequest.count).to eq(1)
      expect(PtoRequest.where(user_id: @user.id)).to be_present
    end
  end

  describe 'POST #create' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @calendar = FactoryBot.create(:calendar)
      sign_in(@user, scope: :user)
    end
    after(:each) do
      User.delete_all
      PtoRequest.delete_all
      Calendar.delete_all
    end

    it 'should allow user with enough credits to request a day / have not requested date off' do
      @pto_request = { user_id: @user.id, reason: 'disneyland',
                       request_date: 10.days.from_now, cost: 10 }
      post :create, params: { pto_request: @pto_request }

      @user.reload
      @calendar.reload

      expect(PtoRequest.count).to eq(1)
      expect(@user.bank_value).to eq(140)
      expect(@calendar.signed_up_agents).to include(@user.name)
    end

    it 'should not allow a user to make a request if they do not have enough credits' do
      post :create, params: { pto_request: { user_id: @user.id, reason: 'also butts', request_date: 10.days.from_now, cost: 160 } }

      @user.reload
      @calendar.reload

      expect(PtoRequest.count).to eq(0)
      expect(@calendar.signed_up_agents).to_not include(@user.name)
      expect(@user.bank_value).to eq(150)
    end

    it 'should not allow a user to make a request if they already have the day off' do
      @calendar.signed_up_agents.push(@user.name)
      @calendar.save
      @calendar.reload

      post :create, params: { pto_request: { user_id: @user.id, reason: 'also butts', request_date: 10.days.from_now, cost: 10 } }
      @user.reload
      @calendar.reload

      expect(PtoRequest.count).to eq(0)
      expect(@calendar.signed_up_total).to eq(1)
      expect(@calendar.signed_up_agents).to include(@user.name)
      expect(@user.bank_value).to eq(150)
    end

    it 'should not allow a user on pip to make a request' do
      @user.on_pip = true
      @user.save
      @user.reload

      @pto_request = { user_id: @user.id, reason: 'disneyland',
                       request_date: 10.days.from_now, cost: 10 }

      post :create, params: { pto_request: @pto_request }
      @user.reload
      @calendar.reload

      expect(PtoRequest.count).to eq(0)
      expect(@user.bank_value).to eq(150)
      expect(@calendar.signed_up_agents).to_not include(@user.name)
    end

    it 'should add no_call_show to user' do
      @pto_request = { user_id: @user.id, reason: 'no call / no show',
                       request_date: 10.days.from_now, cost: 0 }

      post :create, params: { pto_request: @pto_request }

      @user.reload
      @calendar.reload

      expect(PtoRequest.count).to eq(1)
      expect(@user.bank_value).to eq(150)
      expect(@user.no_call_show).to eq(1)
      expect(@calendar.signed_up_agents).to include(@user.name)
    end

    it 'should add make_up_days to user' do
      @pto_request = { user_id: @user.id, reason: 'make up / sick day',
                       request_date: 10.days.from_now, cost: 0 }

      post :create, params: { pto_request: @pto_request }

      @user.reload
      @calendar.reload

      expect(PtoRequest.count).to eq(1)
      expect(@user.bank_value).to eq(150)
      expect(@user.make_up_days).to eq(1)
      expect(@calendar.signed_up_agents).to include(@user.name)
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @calendar = FactoryBot.create(:calendar)
      @pto_request = { user_id: @user.id, reason: 'disneyland',
                       request_date: 10.days.from_now, cost: 10 }
      sign_in(@user, scope: :user)
    end
    after(:each) do
      User.delete_all
      PtoRequest.delete_all
      Calendar.delete_all
    end

    it 'should recredit their bank_value, remove them from the calendar date, allowing them re-request the day' do
      post :create, params: { pto_request: @pto_request }
      @user.reload
      @calendar.reload

      expect(@user.bank_value).to eq(140)
      expect(PtoRequest.count).to eq(1)
      expect(@calendar.signed_up_agents).to include(@user.name)

      request = PtoRequest.find(@user.pto_requests.first.id)
      delete :destroy, params: { id: request }

      @user.reload
      @calendar.reload

      expect(@user.bank_value).to eq(150)
      expect(PtoRequest.count).to eq(0)
      expect(@calendar.signed_up_agents).to_not include(@user.name)
    end

    it 'should remove no_call_show counter from user' do
      @pto_request2 = { user_id: @user.id, reason: 'no call / no show',
                        request_date: 10.days.from_now, cost: 0 }

      post :create, params: { pto_request: @pto_request2 }

      @user.reload
      @calendar.reload

      expect(PtoRequest.count).to eq(1)
      expect(@user.bank_value).to eq(150)
      expect(@user.no_call_show).to eq(1)
      expect(@calendar.signed_up_agents).to include(@user.name)

      request = PtoRequest.find(@user.pto_requests.first.id)
      delete :destroy, params: { id: request }

      @user.reload
      @calendar.reload

      expect(@user.bank_value).to eq(150)
      expect(@user.no_call_show).to eq(0)
      expect(PtoRequest.count).to eq(0)
      expect(@calendar.signed_up_agents).to_not include(@user.name)
    end

    it 'should remove make_up_days to user' do
      @pto_request2 = { user_id: @user.id, reason: 'make up / sick day',
                        request_date: 10.days.from_now, cost: 0 }

      post :create, params: { pto_request: @pto_request2 }

      @user.reload
      @calendar.reload

      expect(PtoRequest.count).to eq(1)
      expect(@user.bank_value).to eq(150)
      expect(@user.make_up_days).to eq(1)
      expect(@calendar.signed_up_agents).to include(@user.name)

      request = PtoRequest.find(@user.pto_requests.first.id)
      delete :destroy, params: { id: request }

      @user.reload
      @calendar.reload

      expect(@user.bank_value).to eq(150)
      expect(@user.make_up_days).to eq(0)
      expect(PtoRequest.count).to eq(0)
      expect(@calendar.signed_up_agents).to_not include(@user.name)
    end
  end

  describe 'POST #excuse_request' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @calendar = FactoryBot.create(:calendar)
      @pto_request = { user_id: @user.id, reason: 'disneyland',
                       request_date: 10.days.from_now, cost: 10 }
      sign_in(@user, scope: :user)
    end
    after(:each) do
      User.delete_all
      PtoRequest.delete_all
      Calendar.delete_all
    end

    it 'should excuse and refund an existing request' do
      post :create, params: { pto_request: @pto_request }
      @calendar.reload
      @user.reload

      expect(PtoRequest.count).to eq(1)
      expect(@user.bank_value).to eq(140)
      expect(@calendar.signed_up_agents).to include(@user.name)

      request = PtoRequest.find(@user.pto_requests.ids.first)
      post :excuse_request, params: { id: request.id }

      request.reload
      @user.reload

      expect(PtoRequest.count).to eq(1)
      expect(@user.bank_value).to eq(150)
      expect(request.excused).to be_truthy
      expect(request.admin_note).to eq("excused by #{@user.name}")
    end

    it 'should excuse and decrease no_call_show counter' do
      @pto_request = { user_id: @user.id, reason: 'no call / no show',
                       request_date: 10.days.from_now, cost: 0 }

      post :create, params: { pto_request: @pto_request }

      @user.reload
      @calendar.reload

      expect(PtoRequest.count).to eq(1)
      expect(@user.no_call_show).to eq(1)
      expect(@calendar.signed_up_agents).to include(@user.name)

      request = PtoRequest.find(@user.pto_requests.ids.first)
      delete :excuse_request, params: { id: request.id }

      @user.reload
      @calendar.reload
      request.reload

      expect(PtoRequest.count).to eq(1)
      expect(@user.no_call_show).to eq(0)
      expect(request.excused).to be_truthy
      expect(request.admin_note).to eq("excused by #{@user.name}")
    end

    it 'should excuse and decrease make_up_days counter' do
      @pto_request = { user_id: @user.id, reason: 'make up / sick day',
                       request_date: 10.days.from_now, cost: 0 }

      post :create, params: { pto_request: @pto_request }

      @user.reload
      @calendar.reload

      expect(PtoRequest.count).to eq(1)
      expect(@user.make_up_days).to eq(1)
      expect(@calendar.signed_up_agents).to include(@user.name)

      request = PtoRequest.find(@user.pto_requests.ids.first)
      delete :excuse_request, params: { id: request.id }

      @user.reload
      @calendar.reload
      request.reload

      expect(PtoRequest.count).to eq(1)
      expect(@user.make_up_days).to eq(0)
      expect(request.excused).to be_truthy
      expect(request.admin_note).to eq("excused by #{@user.name}")
    end
  end

  describe 'DELETE #soft_delete_request' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @calendar = FactoryBot.create(:calendar)
      sign_in(@user, scope: :user)
    end
    after(:each) do
      User.delete_all
      Calendar.delete_all
    end

    it 'should decrease no_call_show counter by 1' do
      @pto_request = { user_id: @user.id, reason: 'no call / no show',
                       request_date: 10.days.from_now, cost: 0 }

      post :create, params: { pto_request: @pto_request }

      @user.reload
      @calendar.reload

      expect(PtoRequest.count).to eq(1)
      expect(@user.bank_value).to eq(150)
      expect(@user.no_call_show).to eq(1)
      expect(@calendar.signed_up_agents).to include(@user.name)

      request = PtoRequest.find(@user.pto_requests.first.id)
      delete :soft_delete, params: { id: request }

      @user.reload
      @calendar.reload

      expect(@user.bank_value).to eq(150)
      expect(@user.no_call_show).to eq(0)
      expect(PtoRequest.count).to eq(1)
      expect(@user.pto_requests.first.is_deleted).to eq(true)
      expect(@calendar.signed_up_agents).to_not include(@user.name)
    end

    it 'should decrease make_up_day counter by 1' do
      @pto_request = { user_id: @user.id, reason: 'make up / sick day',
                       request_date: 10.days.from_now, cost: 0 }

      post :create, params: { pto_request: @pto_request }

      @user.reload
      @calendar.reload

      expect(PtoRequest.count).to eq(1)
      expect(@user.bank_value).to eq(150)
      expect(@user.make_up_days).to eq(1)
      expect(@calendar.signed_up_agents).to include(@user.name)

      request = PtoRequest.find(@user.pto_requests.first.id)
      delete :soft_delete, params: { id: request }

      @user.reload
      @calendar.reload

      expect(@user.bank_value).to eq(150)
      expect(@user.make_up_days).to eq(0)
      expect(PtoRequest.count).to eq(1)
      expect(@user.pto_requests.first.is_deleted).to eq(true)
      expect(@calendar.signed_up_agents).to_not include(@user.name)
    end

    it 'should allow them to retake the day off' do
      @pto_request = { user_id: @user.id, reason: 'disneyland',
                       request_date: 10.days.from_now, cost: 0 }

      post :create, params: { pto_request: @pto_request }

      @user.reload
      @calendar.reload

      expect(PtoRequest.count).to eq(1)
      expect(@user.bank_value).to eq(150)

      request = PtoRequest.find(@user.pto_requests.first.id)
      delete :soft_delete, params: { id: request }

      @user.reload
      @calendar.reload

      expect(@calendar.signed_up_agents).to_not include(@user.name)
      expect(@user.bank_value).to eq(150)
    end
  end
end
