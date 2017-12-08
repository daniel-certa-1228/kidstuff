require 'ocr_space'
require 'rmagick'
require "mini_magick"

class AssignmentsController < ApplicationController
    def new
        @assignment = Assignment.new
    end

    def index
        @assignments = Assignment.all
    end

    def create
        @assignment = Assignment.new(assignment_params)
        to_text
        if @assignment.save
            redirect_to assignments_path
        else
            render 'new'
        end
    end

    def edit
        @assignment = Assignment.find(params[:id])
    end

    def update
        @assignment = Assignment.find(params[:id])
        if @assignment.update(assignment_params)
            redirect_to @assignment
        else
            render 'edit'
        end
    end

    def show
        @assignment = Assignment.find(params[:id])
        @child = Child.where(id: @assignment.child_id)
        @child = @child[0].child_name
    end

    def destroy
        @assignment = Assignment.find(params[:id])
        @assignment.destroy
        redirect_to assignments_path
    end

    def search
        @search = params[:search_string]
        @assignments= Assignment.fuzzy_content_search(@search)
        render 'search'
    end

    def send_pdf
        @assignment = Assignment.find(params[:id])

        s3 = Aws::S3::Client.new(
            region: ENV.fetch('AWS_REGION'),
            access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
            secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
          )

        @jpeg = s3.get_object(bucket: ENV.fetch('S3_BUCKET_NAME'), key: "assignments/#{@assignment.id}.original.jpg")
        @new_pdf = Magick::Image.from_blob(@jpeg.body.read)[0]
        @new_pdf.write("kidstuff_assignment_#{@assignment.id}.pdf")
    end

    def mail_it
        @email = params[:assignment][:email]
        @title = params[:assignment][:title]
        @content = params[:assignment][:content]
        @due_date = params[:assignment][:due_date]
        @attachment = "kidstuff_assignment_#{params[:assignment][:attachment_id]}.pdf"
        AssignmentMailer.assignment_mail(@email, @title, @content, @due_date, @attachment).deliver_later
        redirect_to assignments_path
        File.delete("#{@attachment}")
    end

    private
    def assignment_params
        params.require(:assignment).permit(:title, :due_date, :content, :avatar, :child_id, :user_id )
    end

    def to_text
        image = MiniMagick::Image.new(params[:assignment][:avatar].path)
        image = image.resize "1200x1800"
        resource = OcrSpace::Resource.new(apikey: ENV.fetch('OCR_API_KEY'))
        @assignment.content = resource.clean_convert file: image.path
    end
end
