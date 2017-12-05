class UsersController < ApplicationController

    def new
        @user = User.new
    end

    def create

    end

    def edit
        
    end

    def show

    end

    def update

    end

    private

        def customer_params
            params.require(:user).permit(:email, :password, :password_confirmation, :user_name)
        end
end
