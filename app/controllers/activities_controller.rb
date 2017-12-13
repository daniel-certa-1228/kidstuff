require 'ocr_space'
require 'rmagick'
require 'mini_magick'
require 'icalendar'

class ActivitiesController < ApplicationController

    def new
        @activity = Activity.new
    end

    def index
        @activities = Activity.all
    end

    def create
        @activity = Activity.new(activity_params)
        if is_photo?(params[:activity][:avatar].path)
            to_text
            if @activity.save
                redirect_to activities_path
            else
                render 'new'
            end
        else
            render 'new'
        end
    end

    def edit
        @activity = Activity.find(params[:id])
        @children = Child.all
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

        if @activity.child_id.blank?
            @child = "n/a"
        else
            @child = Child.where(id: @activity.child_id)
            @child = @child[0].child_name
        end

        if @activity.date.blank?
            @parsed_date = "n/a"
        else
            @parsed_date = @activity.date.strftime( '%m/%d/%Y' )
        end

        if @activity.time.blank?
            @parsed_time = "n/a"
        else
            @parsed_time = @activity.time.strftime( '%l:%M%p' )
        end
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
        
        if @activity.child_id.blank?
            @child = "n/a"
        else
            @child = Child.where(id: @activity.child_id)
            @child = @child[0].child_name
        end

        if @activity.date.blank?
            @parsed_date = "n/a"
        else
            @parsed_date = @activity.date.strftime( '%m/%d/%Y' )
        end

        if @activity.time.blank?
            @parsed_time = "n/a"
        else
            @parsed_time = @activity.time.strftime( '%l:%M%p' )
        end

        s3 = Aws::S3::Client.new(
            region: ENV.fetch('AWS_REGION'),
            access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
            secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
          )

        @jpeg = s3.get_object(bucket: ENV.fetch('S3_BUCKET_NAME'), key: "activities/#{@activity.id}.original.jpg")
        @new_pdf = Magick::Image.from_blob(@jpeg.body.read)[0]
        @new_pdf.write("kidstuff_activity_#{@activity.id}.pdf")
    end

    def mail_it
        @email = params[:activity][:email]
        @title = params[:activity][:title]
        @child = params[:activity][:child]
        @content = params[:activity][:content]
        @date = params[:activity][:date]
        @time = params[:activity][:time]
        @attachment = "kidstuff_activity_#{params[:activity][:attachment_id]}.pdf"
        @activity_id = params[:activity][:attachment_id]

        if is_valid?(@email)
            ActivityMailer.activity_mail(@email, @title,  @child, @date, @time, @content, @attachment).deliver_later
            redirect_to activities_path
            sleep 0.5
            File.delete("#{@attachment}")
        else
            redirect_to send_activity_path(@activity_id), notice: 'You must enter a valid email address.'
        end
    end

    def to_icalendar
        @activity = Activity.find(params[:id])
        @start_time = DateTime.parse("#{@activity.date.strftime( '%Y-%m-%d' )} #{@activity.time.strftime( '%H:%M:%S' )}")
        respond_to do |format|
          format.html
          format.ics do
            cal = Icalendar::Calendar.new           
                event = Icalendar::Event.new
                event.dtstart = @start_time
                event.dtend = @start_time + 1.hour
                event.summary = @activity.title
    
                cal.add_event(event)            
                cal.publish
                render plain: cal.to_ical
          end
        end
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

    def is_photo?(file)
        if file.to_s.downcase.include?(".gif") or file.to_s.downcase.include?(".png") or file.to_s.downcase.include?(".jpg") or file.to_s.downcase.include?(".jpeg")
            return true
        else
            return false
        end
    end

    def is_valid?(email)
        regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
        regex.match?(email)
    end
end
