class TeamsController < ApplicationController
    helper_method :sort_col, :sort_dir
    before_action :find_user, only: %i[update_color]
    def index
        if current_user.nil?
            redirect_to login_path
        elsif current_user.position == "Sup"
        else
            redirect_to root_path, notice: "You do not have access to this resource"
        end
        User.any? ? @team_agents = User.where(team: current_user.team).order("#{sort_col} #{sort_dir}") : @team_agents = []
    end

    private
      def sort_col
        User.column_names.include?(params[:sort]) ? params[:sort] : "name"
      end
    
      def sort_dir
        %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
      end

end
