class ChildrenController < ApplicationController

    def new
        @child = Child.new
    end

    def index
        @children = Child.all
    end

    def show
        @child = Child.find(params[:id])
    end

    def create
        @child = Child.new(child_params)
        if @child.save
            # session[:user_id] = @user.id
            redirect_to children_url, notice: "#{@child.child_name} added!"
        else
            render :new
        end
    end

    def edit
        @child = Child.find(params[:id])
    end

    def update
        @child = Child.find(params[:id])
        if @child.update(child_params)
            redirect_to @child
        else
            render 'edit'
        end
    end

    def destroy

    end

    private

        def child_params
            params.require(:child).permit(:child_name, :birthday, :grade_level, :user_id)
        end

end
