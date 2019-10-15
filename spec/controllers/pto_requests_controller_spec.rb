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
      expect(response.header['Content-Type'])
        .to include('application/octet-stream')
      expect(response.status).to eq(200)
    end
  end

  describe 'POST #import_request' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @calendar = FactoryBot.create(:calendar)
      sign_in(@user, scope: :user)
    end

    after(:each) do
      User.delete_all
      Calendar.delete_all
    end

    it 'should import and create requests' do
      requests = [[@calendar.date, @user.email, 8]]

      @user.admin = true
      @user.save

      CSV.open('pto_request.csv', 'w', col_sep: ',', headers: true) do |csv|
        csv << %w[date email shift]
        requests.each { |row| csv << row }
      end

      post :import_request, params: {
        file: fixture_file_upload('pto_request.csv', 'text/csv')
      }

      expect(PtoRequest.count).to eq(1)
      expect(PtoRequest.where(user_id: @user.id)).to be_present
      expect(:notice).to be_present
    end
  end

  describe 'POST #create' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @user2 = FactoryBot.create(:user_with_requests)
      @calendar = FactoryBot.create(:calendar)
      sign_in(@user, scope: :user)
    end
    after(:each) do
      User.delete_all
      PtoRequest.delete_all
      Calendar.delete_all
    end

    it 'should allow user with enough credits to request a day' do
      @pto_request = { user_id: @user.id, reason: 'disneyland',
                       request_date: 10.days.from_now, cost: 10 }
      post :create, params: { pto_request: @pto_request }

      @user.save
      @calendar.save

      expect(PtoRequest.count).to eq(6)
      expect(@user.reload.bank_value).to eq(140)
      expect(@user.reload.pto_requests.count).to eq(1)
      expect(@calendar.reload.signed_up_agents).to include(@user.name)
      expect(response).to redirect_to(root_path)
      expect(ActionMailer::Base.deliveries.count).to increase_by(1)
    end

    it 'should not allow a user to make a request' do
      post :create, params: {
        pto_request: {
          user_id: @user.id, reason: 'also butts',
          request_date: 10.days.from_now, cost: 160
        }
      }

      @user.reload
      @calendar.reload
      expect(PtoRequest.count).to eq(5)
      expect(@calendar.reload.signed_up_agents).to_not include(@user.name)
      expect(@user.reload.bank_value).to eq(150)
      expect(@user.reload.pto_requests.count).to eq(0)
      expect(response).to redirect_to(root_path)
      expect(:alert).to be_present
    end

    it 'should not allow a user to make a request if it is already off' do
      @calendar.signed_up_agents = [@user2.name]
      @calendar.save

      post :create, params: {
        pto_request: {
          user_id: @user2.id,
          reason: 'also butts',
          request_date: 10.days.from_now,
          cost: 10
        }
      }

      expect(@calendar.reload.signed_up_total).to eq(0)
      expect(@user2.reload.pto_requests.count).to eq(5)
      expect(@calendar.reload.signed_up_agents).to include(@user2.name)
      expect(@user2.reload.bank_value).to eq(150)
      expect(response).to redirect_to(root_path)
      expect(:alert).to be_present
    end

    it 'should not allow a user on pip to make a request' do
      @user.on_pip = true
      @user.save

      @pto_request = { user_id: @user.id, reason: 'disneyland',
                       request_date: 10.days.from_now, cost: 10 }

      post :create, params: { pto_request: @pto_request }

      expect(PtoRequest.count).to eq(5)
      expect(@user.reload.bank_value).to eq(150)
      expect(@user.reload.pto_requests.count).to eq(0)
      expect(@calendar.reload.signed_up_agents).to_not include(@user.name)
      expect(response).to redirect_to(root_path)
      expect(:alert).to be_present
    end

    it 'should add no_call_show to user' do
      @pto_request = { user_id: @user.id, reason: 'no call / no show',
                       request_date: 10.days.from_now, cost: 0 }

      post :create, params: { pto_request: @pto_request }

      expect(PtoRequest.count).to eq(6)
      expect(@user.reload.bank_value).to eq(150)
      expect(@user.reload.no_call_show).to eq(1)
      expect(@calendar.reload.signed_up_agents).to include(@user.name)
      expect(response).to redirect_to(show_user_path(@user))
    end

    it 'should add make_up_days to user' do
      @pto_request = { user_id: @user.id, reason: 'make up / sick day',
                       request_date: 10.days.from_now, cost: 0 }

      post :create, params: { pto_request: @pto_request }

      expect(PtoRequest.count).to eq(6)
      expect(@user.reload.bank_value).to eq(150)
      expect(@user.reload.make_up_days).to eq(1)
      expect(@calendar.reload.signed_up_agents).to include(@user.name)
      expect(response).to redirect_to(show_user_path(@user))
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

    it 'should recredit their bank_value/
				remove from the calendar date/
				allow them re-request the day' do
      post :create, params: { pto_request: @pto_request }
      @user.save
      @calendar.save

      expect(@user.reload.bank_value).to eq(140)
      expect(PtoRequest.count).to eq(1)
      expect(@calendar.reload.signed_up_agents).to include(@user.name)

      request = PtoRequest.find(@user.pto_requests.first.id)
      delete :destroy, params: { id: request }
      @user.save
      @calendar.save

      expect(@user.reload.bank_value).to eq(150)
      expect(PtoRequest.count).to eq(0)
      expect(@calendar.reload.signed_up_agents).to_not include(@user.name)
      expect(response).to redirect_to(root_path)
      expect(:notice).to be_present
      expect(ActionMailer::Base.deliveries.count).to increase_by(1)
    end

    it 'should remove no_call_show counter from user' do
      @pto_request2 = { user_id: @user.id, reason: 'no call / no show',
                        request_date: 10.days.from_now, cost: 0 }

      post :create, params: { pto_request: @pto_request2 }

      expect(PtoRequest.count).to eq(1)
      expect(@user.reload.bank_value).to eq(150)
      expect(@user.reload.no_call_show).to eq(1)
      expect(@calendar.reload.signed_up_agents).to include(@user.name)

      request = PtoRequest.find(@user.pto_requests.first.id)
      delete :destroy, params: { id: request }

      expect(@user.reload.bank_value).to eq(150)
      expect(@user.reload.no_call_show).to eq(0)
      expect(PtoRequest.count).to eq(0)
      expect(@calendar.reload.signed_up_agents).to_not include(@user.name)
    end

    it 'should remove make_up_days to user' do
      @pto_request2 = { user_id: @user.id, reason: 'make up / sick day',
                        request_date: 10.days.from_now, cost: 0 }

      post :create, params: { pto_request: @pto_request2 }

      expect(PtoRequest.count).to eq(1)
      expect(@user.reload.bank_value).to eq(150)
      expect(@user.reload.make_up_days).to eq(1)
      expect(@calendar.reload.signed_up_agents).to include(@user.name)

      request = PtoRequest.find(@user.pto_requests.first.id)
      delete :destroy, params: { id: request }

      expect(@user.reload.bank_value).to eq(150)
      expect(@user.reload.make_up_days).to eq(0)
      expect(PtoRequest.count).to eq(0)
      expect(@calendar.reload.signed_up_agents).to_not include(@user.name)
    end
  end

  describe 'POST #excuse_request' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @calendar = FactoryBot.create(:calendar)
      @pto_request = { user_id: @user.id,
                       reason: 'disneyland',
                       request_date: 10.days.from_now,
                       cost: 10,
                       excused: false }
      sign_in(@user, scope: :user)
    end
    after(:each) do
      User.delete_all
      PtoRequest.delete_all
      Calendar.delete_all
    end

    it 'should excuse and refund an existing request' do
      post :create, params: { pto_request: @pto_request }

      expect(PtoRequest.count).to eq(1)
      expect(@user.reload.bank_value).to eq(140)
      expect(@calendar.reload.signed_up_agents).to include(@user.name)

      request = PtoRequest.find(@user.pto_requests.ids.first)
      post :excuse_request, params: { id: request.id }

      expect(PtoRequest.count).to eq(1)
      expect(@user.reload.bank_value).to eq(150)
      expect(request.reload.excused).to be_truthy
      expect(request.reload.admin_note).to eq("excused by #{@user.name}")
      expect(response).to redirect_to(show_user_path(@user))
      expect(ActionMailer::Base.deliveries.count).to increase_by(1)
    end

    it 'should not allow already excused requests from being made' do
      @pto_request2 = { user_id: @user.id,
                        reason: 'excused by Joe Dirt',
                        request_date: 10.days.from_now,
                        cost: 10,
                        excused: true }

      post :create, params: { pto_request: @pto_request }

      expect(PtoRequest.count).to eq(1)
      expect(@user.reload.bank_value).to eq(140)
      expect(@calendar.reload.signed_up_agents).to include(@user.name)

      request = PtoRequest.find(@user.pto_requests.ids.first)
      post :excuse_request, params: { id: request }

      expect(response).to redirect_to(show_user_path(@user))
      expect(:alert).to be_present
      expect(ActionMailer::Base.deliveries.count).to be(0)
    end

    it 'should excuse and decrease no_call_show counter' do
      @pto_request = { user_id: @user.id, reason: 'no call / no show',
                       request_date: 10.days.from_now, cost: 0, excused: false }

      post :create, params: { pto_request: @pto_request }

      expect(PtoRequest.count).to eq(1)
      expect(@user.reload.no_call_show).to eq(1)
      expect(@calendar.reload.signed_up_agents).to include(@user.name)

      request = PtoRequest.find(@user.pto_requests.ids.first)
      delete :excuse_request, params: { id: request }

      expect(PtoRequest.count).to eq(1)
      expect(@user.reload.no_call_show).to eq(0)
      expect(request.reload.excused).to be_truthy
      expect(request.reload.admin_note).to eq("excused by #{@user.name}")
      expect(response).to redirect_to(show_user_path(@user))
      expect(ActionMailer::Base.deliveries.count).to increase_by(1)
    end

    it 'should excuse and decrease make_up_days counter' do
      @pto_request = { user_id: @user.id, reason: 'make up / sick day',
                       request_date: 10.days.from_now, cost: 0, excused: false }

      post :create, params: { pto_request: @pto_request }

      expect(PtoRequest.count).to eq(1)
      expect(@user.reload.make_up_days).to eq(1)
      expect(@calendar.reload.signed_up_agents).to include(@user.name)

      request = PtoRequest.find(@user.pto_requests.ids.first)
      delete :excuse_request, params: { id: request.id }

      expect(PtoRequest.count).to eq(1)
      expect(@user.reload.make_up_days).to eq(0)
      expect(request.reload.excused).to be_truthy
      expect(request.reload.admin_note).to eq("excused by #{@user.name}")
      expect(response).to redirect_to(show_user_path(@user))
      expect(ActionMailer::Base.deliveries.count).to increase_by(1)
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

      expect(PtoRequest.count).to eq(1)
      expect(@user.reload.bank_value).to eq(150)
      expect(@user.reload.no_call_show).to eq(1)
      expect(@calendar.reload.signed_up_agents).to include(@user.name)

      request = PtoRequest.find(@user.pto_requests.first.id)
      delete :soft_delete, params: { id: request }

      expect(@user.reload.bank_value).to eq(150)
      expect(@user.reload.no_call_show).to eq(0)
      expect(PtoRequest.count).to eq(1)
      expect(@user.reload.pto_requests.first.is_deleted).to eq(true)
      expect(@calendar.reload.signed_up_agents).to_not include(@user.name)
      expect(ActionMailer::Base.deliveries.count).to increase_by(1)
    end

    it 'should decrease make_up_day counter by 1' do
      @pto_request = { user_id: @user.id, reason: 'make up / sick day',
                       request_date: 10.days.from_now, cost: 0 }

      post :create, params: { pto_request: @pto_request }

      expect(PtoRequest.count).to eq(1)
      expect(@user.reload.bank_value).to eq(150)
      expect(@user.reload.make_up_days).to eq(1)
      expect(@calendar.reload.signed_up_agents).to include(@user.name)

      request = PtoRequest.find(@user.pto_requests.first.id)
      delete :soft_delete, params: { id: request }

      expect(@user.reload.bank_value).to eq(150)
      expect(@user.reload.make_up_days).to eq(0)
      expect(PtoRequest.count).to eq(1)
      expect(@user.reload.pto_requests.first.is_deleted).to eq(true)
      expect(@calendar.reload.signed_up_agents).to_not include(@user.name)
      expect(ActionMailer::Base.deliveries.count).to increase_by(1)
    end

    it 'should allow them to retake the day off' do
      @pto_request = { user_id: @user.id, reason: 'disneyland',
                       request_date: 10.days.from_now, cost: 0 }

      post :create, params: { pto_request: @pto_request }

      expect(PtoRequest.count).to eq(1)
      expect(@user.reload.bank_value).to eq(150)

      request = PtoRequest.find(@user.pto_requests.first.id)
      delete :soft_delete, params: { id: request }

      expect(@calendar.reload.signed_up_agents).to_not include(@user.name)
      expect(@user.reload.bank_value).to eq(150)
    end
  end
end
