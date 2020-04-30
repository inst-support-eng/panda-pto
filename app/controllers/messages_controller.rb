##
# Messages Controller
class MessagesController < ApplicationController
  require 'csv'
  before_action :login_required
  before_action :set_message, only: %i[show edit update destroy]

  def export
    @messages = Message.all
    respond_to do |format|
      format.csv do
        send_data @messages.to_csv
      end
    end
  end

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

  def batsignal_next()
    author = message_params[:author]
    message = message_params[:message]
    agents = message_params[:recipients].split(',')
    numbers = []
    names = []

    agents.each do |a|
      u = User.find(a)
      numbers.push(u.phone_number) unless u.phone_number.nil?
      names.push(u.name)
    end

    @message = Message.new
    @message.message = message
    @message.recipients = names
    @message.recipient_numbers = numbers

    batch = numbers.each_slice(10).to_a
    responses = []

    batch.each do |b|
      # res = SharpenAPI.send_sms(@message.message, b)
      responses.push(res)
    end

    if responses.uniq.size == 1 || responses.uniq.size == 0
      @message.status = responses[0]
    else
      @message.status = responses.zip(batch)
    end
    yeet.fleet
    @message.save

    render json: {
      author: author,
      message: message,
      agents: agents,
      numbers: numbers,
      names: names
    }

  end

  # POST /messages
  # POST /messages.json
  def create
    if message_params[:source] == "bat-signal-next"
      batsignal_next()
    else

      @message = Message.new(message_params)
      
      @message.recipients = @message.recipients.uniq
      @message.recipient_numbers = @message.recipient_numbers.uniq

      res = SharpenAPI.send_sms(@message.message, @message.recipient_numbers)

      @message.status = (res ? 'success' : 'failure')

      @message.save

      # !todo this does not work
      if res == 1
        redirect_to admin_bat_signal_path, notice: 'Message was successfully sent'
      else
        redirect_to admin_bat_signal_path, alert: 'Message was not sucessful'
      end
    end
  end

  def bat_signal
    # disallow regular users from sending sms messages to other users
    unless current_user.admin == false || current_user.position != 'Sup' || @user != current_user
      return redirect_back(fallback_location: root_path),
        alert: 'You do not have sufficent privlages to access this.'
    end
    @agents = User.all
    @users_team = users_by_team
    @users_off_today = users_off_today
    @users_not_working = users_not_working
    @last_message = Message.last
  end

  def bat_signal_next
    unless current_user.admin == false || current_user.position != 'Sup' || @user != current_user
      return redirect_back(fallback_location: root_path),
        alert: 'You do not have sufficent privlages to access this.'
    end
    # things that aren't needed
    @agents = User.where.not(:is_deleted => true)
    @users_team = users_by_team
    @users_off_today = users_off_today
    @users_not_working = users_not_working

    @last_message = Message.last

    @filterrific = initialize_filterrific(
      User.where.not(:is_deleted => true),
      params[:filterrific],
      select_options: {
        with_team: User.options_for_team,
        working_today: User.options_for_working,
      },
      persistence_id: "shared_key",
      # default_filter_params: {},
      available_filters: [:with_team, :working_today],
      sanitize_params: true,
    ) or return
    @users = @filterrific.find.page(params[:page])
 
    respond_to do |format|
      format.html
      format.js
    end

  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_message
    @message = Message.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def message_params
    params.require(:message).permit(
      :message,
      :author,
      :recipients,
      :recipient_numbers,
      :source
    )
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
					USERS.PHONE_NUMBER,
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
