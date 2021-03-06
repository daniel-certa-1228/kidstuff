require 'ocr_space'
require 'rmagick'
require 'mini_magick'
require 'icalendar'

class ActivitiesController < ApplicationController

    def new
        @activity = Activity.new
    end

    def index
        @activities = Activity.all.order('created_at DESC')
        # indexed with newest at top
    end

    def create
        begin
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
        rescue NoMethodError => e
            flash[:error] = "Please attach an image!"
            redirect_to new_activity_path
        end
    end

    def edit
        @activity = Activity.find(params[:id])
        @children = Child.where({user_id: session[:user_id]})
        #children loaded from DB to populate select menu
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
        # logic to display 'n/a' for blank field
        if @activity.title.blank?
            @title = "n/a"
        else
            @title = @activity.title
        end
        # logic to display 'n/a' for blank field
        if @activity.child_id.blank?
            @child = "n/a"
        else
            @child = Child.where(id: @activity.child_id)
            @child = @child[0].child_name
        end
        # logic to display 'n/a' for blank field
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
        @activities= Activity.fuzzy_content_search(@search).order('created_at DESC')
        render 'search'
    end

    def send_pdf
        @user = User.find(session[:user_id])
        @activity = Activity.find(params[:id])
        # logic to display 'n/a' for blank field        
        if @activity.title.blank?
            @title = "n/a"
        else
            @title = @activity.title
        end
        # logic to display 'n/a' for blank field        
        if @activity.child_id.blank?
            @child = "n/a"
        else
            @child = Child.where(id: @activity.child_id)
            @child = @child[0].child_name
        end
        # logic to display 'n/a' for blank field
        if @activity.date.blank?
            @parsed_date = "n/a"
        else
            @parsed_date = @activity.date.strftime( '%m/%d/%Y' )
        end
        # logic to display 'n/a' for blank field
        if @activity.time.blank?
            @parsed_time = "n/a"
        else
            @parsed_time = @activity.time.strftime( '%l:%M%p' )
        end
        ##### GENERATE PDF ######################
        #connect to s3 bucket to get the jpg
        s3 = Aws::S3::Client.new(
            region: ENV.fetch('AWS_REGION'),
            access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
            secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
          )

        @jpeg = s3.get_object(bucket: ENV.fetch('S3_BUCKET_NAME'), key: "activities/#{@activity.id}.original.jpg")
        @new_pdf = Magick::Image.from_blob(@jpeg.body.read)[0]
        #convert from blob to pdf & save to local disk
        @new_pdf.write("kidstuff_activity_#{@activity.id}.pdf")
        ##### GENERATE ICS ######################
        if @activity.date.present?
            ical_attachment(@activity.date, @activity.time, @activity.title, @activity.content, @activity.id)
            @cal_attached = true
        else
            @cal_attached = false
        end  
    end

    def mail_it
        @email = params[:activity][:email]
        @user_name = params[:activity][:user_name]
        @user_email = params[:activity][:user_email]
        @title = params[:activity][:title]
        @child = params[:activity][:child]
        @content = params[:activity][:content]
        @date = params[:activity][:date]
        @time = params[:activity][:time]
        @cal_attached = (params[:activity][:cal_attached])
        @attachment = "kidstuff_activity_#{params[:activity][:attachment_id]}.pdf"
        @activity_id = params[:activity][:attachment_id]

        if @cal_attached == "true"
            @attachment_cal = "#{params[:activity][:title]} | ID ##{params[:activity][:attachment_id]}.ics"
        else
            @attachment_cal = []
        end
        
        if is_valid?(@email)
            ActivityMailer.activity_mail(@email, @user_name, @user_email, @title, @child, @date, @time, @content, @attachment, @attachment_cal).deliver_later
            redirect_to activities_path
            sleep 0.5 #half-second delay ensures that the file is still there when the email is sent
            File.delete("#{@attachment}") #file deleted from root after copy is sent
            if @attachment_cal != []
                File.delete("#{@attachment_cal}")#file deleted from root after copy is sent
            end
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
                event.description = @activity.content
    
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
        image = image.resize "1200x1800" #image needs to be resized to avoid sending too large a file to OCR Space
        resource = OcrSpace::Resource.new(apikey: ENV.fetch('OCR_API_KEY'))
        #clean_convert takes the parsed text and strips out newlines
        #@activity.content is then saved to db
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

    def ical_attachment(date, time, title, content, id)
        if time.blank?
            @start_time = DateTime.parse("#{date.strftime( '%Y-%m-%d' )} 08:00:00}")
        else
            @start_time = DateTime.parse("#{date.strftime( '%Y-%m-%d' )} #{time.strftime( '%H:%M:%S' )}")
        end

        if title == ""
            @title = "Untitled Event"
        else
            @title = title
        end

        cal = Icalendar::Calendar.new           
        event = Icalendar::Event.new
        event.dtstart = @start_time
        event.dtend = @start_time + 1.hour
        event.summary = @title
        event.description = content

        cal.add_event(event)            
        cal.publish

        file = File.new("#{@title} | ID ##{id}.ics", "w+")
        file.write(cal.to_ical)
        file.close
    end
end
