class SessionsController < ApplicationController

    def index
    end

    def new
    end

    def create
        user = User.find_by(email: params[:email])

        if user && user.authenticate(params[:password])
            session[:user_id] = user.id
            redirect_to root_url, notice: "Thank you for logging in to Kid Stuff!"
        else
            flash.now.notice = 'Email or password is invalid'
            render :new
        end
    end

    def destroy
        session[:user_id] = nil
        redirect_to root_url, notice: 'Logged out, see you again soon!'
    end
end
