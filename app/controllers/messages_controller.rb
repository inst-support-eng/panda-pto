class MessagesController < ApplicationController
  before_action :login_required
  before_action :set_message, only: %i[show edit update destroy]

  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.all
  end

  # GET /messages/1
  # GET /messages/1.json
  def show; end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit; end

  # POST /messages
  # POST /messages.json
  def create
		@message = Message.new(message_params)
		
		if @message.save
			SharpenAPI.send_sms(@message.message, @message.recipient_numbers)
      redirect_to admin_bat_signal_path, notice: 'Message was successfully send.'
    else
      format.html { render :new }
      format.json { render json: @message.errors, status: :unprocessable_entity }
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message.destroy
    respond_to do |format|
      format.html { redirect_to messages_url, notice: 'Message was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def bat_signal
    @agents = User.all
    @users_team = users_by_team
    @users_off_today = users_off_today
    @users_not_working = users_not_working
    @last_message = Message.last
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_message
    @message = Message.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def message_params
    params.require(:message).permit(:message, :author, :recipients, :recipient_numbers)
  end

  def users_off_today
    agents_off_query = <<-SQL
				SELECT
					USERS.ID,
					USERS.NAME,
					USERS.PHONE_NUMBER,
					USERS.WORK_DAYS
				FROM USERS
				WHERE NOT(
					USERS.WORK_DAYS @> ARRAY[DATE_PART('dow', NOW())]::integer[]
				)
				AND IS_DELETED IS NOT TRUE
    SQL

    agents_off = ActiveRecord::Base.connection.execute(agents_off_query)
    agents_off
  end

  def users_not_working
    agents_not_working_query = <<-SQL
				SELECT
					USERS.ID,
					USERS.NAME,
					CURRENT_TIME
				FROM USERS
				WHERE NOT (
					USERS.WORK_DAYS @> ARRAY[DATE_PART('dow', NOW())]::integer[]
				)
				AND(
					USERS.START_TIME > EXTRACT(HOUR FROM CURRENT_TIME)::varchar
					OR USERS.END_TIME < EXTRACT(HOUR FROM CURRENT_TIME)::varchar
				)
				AND IS_DELETED IS NOT TRUE
    SQL

    agents_not_working = ActiveRecord::Base.connection.execute(agents_not_working_query)
    agents_not_working
  end

  def users_by_team
    agents_by_team = User.where(team: current_user.team)
    agents_by_team
  end
end
