module ApplicationHelper
    private
    # set current user
    def logged_in?
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
    
end
