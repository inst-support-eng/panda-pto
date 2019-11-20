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
          recipients: [@user.name],
          recipient_numbers: [@user.phone_number],
          message: 'test'
        }

        post :create, params: { message: @new_message }
        expect(Message.count).to be(2)
      end

      it 'should not include duplicates' do
        sign_in(@admin, scope: :user)

        @new_message = {
          author: @admin.id,
          recipients: [@user.name, @user.name],
          recipient_numbers: [@user.phone_number, @user.phone_number],
          message: 'test'
        }

        post :create, params: { message: @new_message }
        expect(@message.recipients.count).to eq(1)
        expect(@message.recipient_numbers.count).to eq(1)
        expect(Message.count).to be(2)
      end
    end
  end
end
