require 'rails_helper'

RSpec.describe AdminController, type: :controller do
  describe 'GET #index' do
    before(:each) do
      @user = FactoryBot.create(:user)
    end

    after(:each) do
      User.destroy_all
    end

    it 'should render for admin' do
      @user.admin = true
      sign_in(@user, scope: :user)

      get :index
      expect(response).to have_http_status(:success)
      expect(response).to render_template('admin/index')
    end

    it 'should not allow non admin access' do
      sign_in(@user, scope: :user)

      get :index
      expect(response).to render_template(root_path)
      expect(:alert).to be_present
    end

    it 'should not allow non-signed in users access' do
      get :index
      expect(response).to redirect_to(login_path)
      expect(:alert).to be_present
    end
  end

  describe 'GET #coverage' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @calendar = FactoryBot.create(:calendar)
    end

    after(:each) do
      User.destroy_all
    end

    it 'should return json for admin' do
      @user.admin
      sign_in(@user, scope: :user)
      get :coverage, params: { date: @calendar.date }

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['date'].to_date).to eq(@calendar.date)
    end

    it 'should not allow non-signed in users access' do
      get :coverage, params: { date: @calendar.date }

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(login_path)
      expect(:alert).to be_present
    end
  end

  describe '#GET deleted_users' do
    before(:each) do
      @admin = FactoryBot.create(:user)
      @admin.admin = true
      @admin.save

      @user = FactoryBot.create(:user)
      @user.is_deleted = true
      @user.save
    end

    after(:each) do
      User.destroy_all
    end

    it 'should return list of deleted users' do
      sign_in(@admin, scope: :user)

      get :deleted_users

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).length).to eq(1)
      expect(JSON.parse(response.body)[0]['id']).to eq(@user.id)
    end

    it 'should not allow non-logged in users to access' do
      get :deleted_users

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(login_path)
      expect(:alert).to be_present
    end
  end
end
