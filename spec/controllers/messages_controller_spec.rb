require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'POST #create' do
    before(:each) do
      @admin = FactoryBot.create(:user, :admin)
      @user = FactoryBot.create(:user)
      @message = FactoryBot.create(:message)
    end

    after(:each) do
      User.destroy_all
      Message.destroy_all
    end

    context 'with valid params' do
      it 'creates a new Message' do
        sign_in(@admin, scope: :user)

        @new_message = {
          author: @admin.id,
          recipients: 'Thor',
          recipient_numbers: '123-123-1234',
					message: 'spec test'
        }

        post :create, {params: @new_message}
        puts response
        expect(Message.count).to be(1)
      end

      it 'stays on page and gives notice' do
        sign_in(@admin, scope: :user)
        @new_message = {
          author: @admin.id,
          recipients: [@user.name],
          recipient_numbers: [@user.phone_number],
          message: 'test'
        }

        post :create, params: { message: @new_message }
        expect(Message.count).to be(1)
        expect(response).to render_template(admin_bat_signal_path)
        expect(:alert).to be_present
      end
    end
  end
end
