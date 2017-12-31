require 'ocr_space'
require 'rmagick'
require 'mini_magick'
require 'icalendar'

class AssignmentsController < ApplicationController
    def new
        @assignment = Assignment.new
    end

    def index
        @assignments = Assignment.all.order('created_at DESC')
        # indexed with newest at top

    end

    def create
        begin
            @assignment = Assignment.new(assignment_params)
            if is_photo?(params[:assignment][:avatar].path)
                to_text
                if @assignment.save
                    redirect_to assignments_path
                else
                    render 'new'
                end
            else
                render 'new'            
            end
        rescue NoMethodError => e
            # puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ #{e}"
            flash[:error] = "Please attach an image!"
            redirect_to new_assignment_path
        end
    end

    def edit
        @assignment = Assignment.find(params[:id])
        @children = Child.all
        #children loaded from DB to populate select menu
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
        # logic to display 'n/a' for blank field
        if @assignment.title.blank?
            @title = "n/a"
        else
            @title = @assignment.title
        end
        # logic to display 'n/a' for blank field
        if @assignment.child_id.blank?
            @child = "n/a"
        else
            @child = Child.where(id: @assignment.child_id)
            @child = @child[0].child_name
        end
        # logic to display 'n/a' for blank field
        if @assignment.due_date.blank?
            @parsed_date = "n/a"
        else
            @parsed_date = @assignment.due_date.strftime( '%m/%d/%Y' )
        end
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
        @user = User.find(session[:user_id])

        @assignment = Assignment.find(params[:id])
        # logic to display 'n/a' for blank field
        if @assignment.title.blank?
            @title = "n/a"
        else
            @title = @assignment.title
        end
        # logic to display 'n/a' for blank field
        if @assignment.child_id.blank?
            @child = "n/a"
        else
            @child = Child.where(id: @assignment.child_id)
            @child = @child[0].child_name
        end
        # logic to display 'n/a' for blank field
        if @assignment.due_date.blank?
            @parsed_date = "n/a"
        else
            @parsed_date = @assignment.due_date.strftime( '%m/%d/%Y' )
        end

        #connect to s3 bucket to get the jpg
        s3 = Aws::S3::Client.new(
            region: ENV.fetch('AWS_REGION'),
            access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
            secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
          )

        @jpeg = s3.get_object(bucket: ENV.fetch('S3_BUCKET_NAME'), key: "assignments/#{@assignment.id}.original.jpg")
        @new_pdf = Magick::Image.from_blob(@jpeg.body.read)[0]
        #convert from blob to pdf & save to local disk
        @new_pdf.write("kidstuff_assignment_#{@assignment.id}.pdf")
    end

    def mail_it
        @email = params[:assignment][:email]
        @user_name = params[:assignment][:user_name]
        @user_email = params[:assignment][:user_email]
        @title = params[:assignment][:title]
        @child = params[:assignment][:child]
        @content = params[:assignment][:content]
        @due_date = params[:assignment][:due_date]
        @attachment = "kidstuff_assignment_#{params[:assignment][:attachment_id]}.pdf"
        @assignment_id = params[:assignment][:attachment_id]

        if is_valid?(@email)
            AssignmentMailer.assignment_mail(@email, @user_name, @user_email, @title, @child, @due_date, @content, @attachment).deliver_later
            redirect_to assignments_path
            sleep 0.5 #half-second delay ensures that the file is still there when the email is sent
            File.delete("#{@attachment}") #file deleted from root level after copy is sent
        else
            redirect_to send_assignment_path(@assignment_id), notice: 'You must enter a valid email address.'
        end
    end

    def to_icalendar
        @assignment = Assignment.find(params[:id])
        @start_time = DateTime.parse("#{@assignment.due_date.strftime( '%Y-%m-%d' )} 08:00:00")
        puts @start_time
        respond_to do |format|
          format.html
          format.ics do
            cal = Icalendar::Calendar.new           
                event = Icalendar::Event.new
                event.dtstart = @start_time
                event.dtend = @start_time + 1.hour
                event.summary = @assignment.title
    
                cal.add_event(event)            
                cal.publish
                render plain: cal.to_ical
          end
        end
    end

    private
    def assignment_params
        params.require(:assignment).permit(:title, :due_date, :content, :avatar, :child_id, :user_id )
    end

    def to_text
        image = MiniMagick::Image.new(params[:assignment][:avatar].path)
        image = image.resize "1200x1800" #image needs to be resized to avoid sending too large a file to OCR Space
        resource = OcrSpace::Resource.new(apikey: ENV.fetch('OCR_API_KEY'))
        #clean_convert takes the parsed text and strips out newlines
        #@activity.content is then saved to db
        @assignment.content = resource.clean_convert file: image.path
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
