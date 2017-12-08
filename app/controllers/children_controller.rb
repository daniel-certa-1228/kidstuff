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
        @child = Child.find(params[:id])
        nuke_records(@child.id)
        @child.destroy
        redirect_to children_path
    end

    private

        def child_params
            params.require(:child).permit(:child_name, :birthday, :grade_level, :user_id)
        end

        def nuke_records(child_id)
            @assignments = Assignment.where(child_id: child_id)
            @activities = Activity.where(child_id: child_id)
            @artworks = Artwork.where(child_id: child_id)
            @artworks.each do |artwork|
                artwork.destroy
            end
            @activities.each do |activity|
                activity.destroy
            end
            @assignments.each do |assignment|
                assignment.destroy
            end
        end

end
