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
      sign_in(@user, scope: :user)
      expect(@user.pto_requests.count).to eq(5)

      delete :destroy, params: { user_id: @user.id }

      expect(PtoRequest.count).to eq(0)
      expect(User.count).to eq(0)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(admin_path)
    end

    it 'should not allow non-logged in users to delete' do
      delete :destroy, params: { user_id: @user.id }

      expect(PtoRequest.count).to eq(5)
      expect(response).to redirect_to(login_path)
      expect(response).to have_http_status(:redirect)
      expect(:alert).to be_present
    end
  end

  describe 'Get #current' do
    before(:each) do
      @user = FactoryBot.create(:user)
    end
    after(:each) do
      User.delete_all
    end

    it 'should render current user json' do
      sign_in(@user, scope: :user)
      get :current

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['id']).to eq(@user.id)
    end

    it 'should not render for non-signed in users' do
      get :current

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(login_path)
      expect(:alert).to be_present
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
      sign_in(@user, scope: :user)
      put :update_shift, params: { user_id: @user.id }

      expect(@user.reload.ten_hour_shift).to eq(true)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(show_user_path(@user))
    end

    it 'should update ten_hour_shift = true to false' do
      sign_in(@user, scope: :user)
      @user.ten_hour_shift = true
      @user.save

      expect(@user.reload.ten_hour_shift).to eq(true)

      put :update_shift, params: { user_id: @user.id }

      expect(@user.reload.ten_hour_shift).to eq(false)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(show_user_path(@user))
    end

    it 'should redirect non-logged in users to login_path' do
      put :update_shift, params: { user_id: @user.id }

      expect(@user.reload.ten_hour_shift).to eq(false)

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(login_path)
      expect(:alert).to be_present
    end
  end

  describe 'POST #update_admin' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @admin = FactoryBot.create(:user, :admin)
    end
    after(:each) do
      User.delete_all
    end

    it 'should admin = false to true' do
      sign_in(@user, scope: :user)
      post :update_admin, params: { user_id: @user.id }

      expect(@user.reload.admin).to be(true)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(show_user_path(@user))
    end

    it 'should admin = true to false' do
      sign_in(@admin, scope: :user)
      expect(@admin.admin).to be(true)

      post :update_admin, params: { user_id: @admin.id }

      expect(@admin.reload.admin).to be(false)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(show_user_path(@admin))
    end

    it 'should redirect non-logged in users to login_path' do
      put :update_admin, params: { user_id: @user.id }

      expect(@user.reload.admin).to eq(false)

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(login_path)
      expect(:alert).to be_present
    end
  end

  describe 'POST #update_pip' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @on_pip_user = FactoryBot.create(:user, :on_pip_user)
    end
    after(:each) do
      User.delete_all
    end

    it 'should update on_pip = false to true' do
      sign_in(@user, scope: :user)
      post :update_pip, params: { user_id: @user.id }

      expect(@user.reload.on_pip).to be(true)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(show_user_path(@user))
    end

    it 'should update false on_pip = true to false' do
      sign_in(@on_pip_user, scope: :user)

      expect(@on_pip_user.on_pip).to be(true)

      post :update_pip, params: { user_id: @on_pip_user.id }

      expect(@on_pip_user.reload.on_pip).to be(false)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(show_user_path(@on_pip_user))
    end

    it 'should redirect non-logged in users to login_path' do
      put :update_pip, params: { user_id: @user.id }

      expect(@user.reload.on_pip).to eq(false)

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(login_path)
      expect(:alert).to be_present
    end
  end

  describe 'DELETE #soft_delete' do
    before(:each) do
      @user = FactoryBot.create(:user_with_requests)
      @calendar = FactoryBot.create(:calendar)
      sign_in(@user, scope: :user)
    end

    after(:each) do
      User.destroy_all
      Calendar.destroy_all
    end

    it 'should flag the user.is_deleted = 1' do
      delete :soft_delete, params: { id: @user.id }

      expect(User.count).to eq(1)
      expect(@user.reload.is_deleted).to eq(true)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(show_user_path(@user))
    end

    it 'should remove active pto_requests from the user' do
      delete :soft_delete, params: { id: @user.id }

      expect(User.count).to eq(1)
      expect(@user.reload.pto_requests.where(is_deleted: 1).count).to eq(5)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(show_user_path(@user))
    end
  end

  describe 'POST #restore_user' do
    before(:each) do
      @deleted_user = FactoryBot.create(:user, :deleted_user)
      @user = FactoryBot.create(:user)
    end

    after(:each) do
      User.destroy_all
    end

    it 'should restore a deleted user' do
      sign_in(@user, scope: :user)
      post :restore_user, params: { id: @deleted_user.id }

      expect(@deleted_user.reload.is_deleted).to eq(false)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(show_user_path(@deleted_user))
    end

    it 'should give error if user is not deleted' do
      sign_in(@user, scope: :user)
      post :restore_user, params: { id: @user.id }

      expect(@user.reload.is_deleted).to eq(false)
      expect(response.body).to include('is not not deleted')
    end

    it 'should redirect non-logged in user' do
      post :restore_user, params: { id: @user.id }

      expect(@user.reload.is_deleted).to eq(false)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(login_path)
    end
  end
end
