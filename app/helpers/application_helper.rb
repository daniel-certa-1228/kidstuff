module ApplicationHelper
    private
    
    def logged_in?
        @current_user ||= User.find(session[:user_id]) if session[:user_id]  # puts @current_customer
    end
    
end
