require 'ocr_space'
require 'rmagick'
require "mini_magick"

class ActivitiesController < ApplicationController

    def new
        @activity = Activity.new
    end

    def index
        @activities = Activity.all
    end

    def create
        @activity = Activity.new(activity_params)
        to_text
        if @activity.save
            redirect_to activities_path
        else
            render 'new'
        end
    end

    def edit
        @activity = Activity.find(params[:id])
    end

    def update
        @activity = Activity.find(params[:id])
        if @activity.update(activity_params)
            redirect_to @activity
        else
            render 'edit'
        end
    end

    def show
        @activity = Activity.find(params[:id])
    end

    def destroy
        @activity = Activity.find(params[:id])
        @activity.destroy
        redirect_to activities_path
    end

    def search
        @search = params[:search_string]
        @activities= Activity.fuzzy_content_search(@search)
        render 'search'
    end

    def send_pdf
        @activity = Activity.find(params[:id])

        s3 = Aws::S3::Client.new(
            region: ENV.fetch('AWS_REGION'),
            access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
            secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
          )

        @jpeg = s3.get_object(bucket: ENV.fetch('S3_BUCKET_NAME'), key: "activities/#{@activity.id}.original.JPG")
        @new_pdf = Magick::Image.from_blob(@jpeg.body.read)[0]
        @new_pdf.write("kidstuff_activity_#{@activity.id}.pdf")
    end

    def mail_it
        @email = params[:activity][:email]
        @title = params[:activity][:title]
        @content = params[:activity][:content]
        @date = params[:activity][:date]
        @time = params[:activity][:time]
        @attachment = "kidstuff_activity_#{params[:activity][:attachment_id]}.pdf"
        ActivityMailer.activity_mail(@email, @title, @content, @date, @time, @attachment).deliver_later
        redirect_to activities_path
        File.delete("#{@attachment}")
    end

    private
    def activity_params
        params.require(:activity).permit(:title, :date, :time, :content, :avatar, :child_id, :user_id )
    end

    def to_text
        image = MiniMagick::Image.new(params[:activity][:avatar].path)
        image = image.resize "1200x1800"
        resource = OcrSpace::Resource.new(apikey: ENV.fetch('OCR_API_KEY'))
        @activity.content = resource.clean_convert file: image.path
    end
end
