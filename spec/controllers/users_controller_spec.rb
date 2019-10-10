require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'DELETE #destroy' do
    before(:each) do
      @user = FactoryBot.create(:user_with_requests)
    end

    after(:each) do
      User.delete_all
    end

    it 'should delete user and all requests' do
      expect(@user.pto_requests.count).to eq(5)

      delete :destroy, params: { user_id: @user.id }

      expect(PtoRequest.count).to eq(0)
      expect(User.count).to eq(0)
      expect(response).to redirect_to(admin_path)
    end
  end

  describe 'Get #current' do
    before(:each) do
      @user = FactoryBot.create(:user)
      sign_in(@user, scope: :user)
    end
    after(:each) do
      User.delete_all
    end

    it 'should render current user json' do
      get :current
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PUT #update_shift' do
    before(:each) do
      @user = FactoryBot.create(:user)
    end
    after(:each) do
      User.delete_all
    end

    it 'should update ten_hour_shift = false to true' do
      put :update_shift, params: { user_id: @user.id }

      expect(@user.reload.ten_hour_shift).to be(true)
      expect(response).to redirect_to(show_user_path(@user))
    end

    it 'should update ten_hour_shift = true to false' do
      @user.ten_hour_shift = true
      @user.save

      expect(@user.reload.ten_hour_shift).to be(true)

      put :update_shift, params: { user_id: @user.id }

      expect(@user.reload.ten_hour_shift).to be(false)
      expect(response).to redirect_to(show_user_path(@user))
    end
  end

  describe 'POST #update_admin' do
    before(:each) do
      @user = FactoryBot.create(:user)
    end
    after(:each) do
      User.delete_all
    end

    it 'should admin = false to true' do
      post :update_admin, params: { user_id: @user.id }

      expect(@user.reload.admin).to be(true)
      expect(response).to redirect_to(show_user_path(@user))
    end

    it 'should admin = true to false' do
      @user.admin = true
      @user.save

      expect(@user.reload.admin).to be(true)

      post :update_admin, params: { user_id: @user.id }

      expect(@user.reload.admin).to be(false)
      expect(response).to redirect_to(show_user_path(@user))
    end
  end

  describe 'POST #update_pip' do
    before(:each) do
      @user = FactoryBot.create(:user)
    end
    after(:each) do
      User.delete_all
    end

    it 'should update on_pip = false to true' do
      post :update_pip, params: { user_id: @user.id }

      expect(@user.reload.on_pip).to be(true)
      expect(response).to redirect_to(show_user_path(@user))
    end

    it 'should update false on_pip = true to false' do
      @user.on_pip = true
      @user.save

      expect(@user.reload.on_pip).to be(true)

      post :update_pip, params: { user_id: @user.id }

      expect(@user.reload.on_pip).to be(false)
      expect(response).to redirect_to(show_user_path(@user))
    end
  end

  describe 'POST #soft_delete' do
    before(:each) do
      @user = FactoryBot.create(:user_with_requests)
      @calendar = FactoryBot.create(:calendar)
    end

    after(:each) do
      User.destroy_all
      Calendar.destroy_all
    end

    it 'should flag the user.is_deleted = 1' do
      delete :soft_delete, params: { id: @user.id }

      expect(User.count).to eq(1)
      expect(@user.reload.is_deleted).to eq(true)
      expect(response).to redirect_to(show_user_path(@user))
    end

    it 'should remove active pto_requests from the user' do
      delete :soft_delete, params: { id: @user.id }

      @user.reload

      expect(User.count).to eq(1)
      expect(@user.reload.pto_requests.where(is_deleted: 1).count).to eq(5)
      expect(response).to redirect_to(show_user_path(@user))
    end
  end
end
