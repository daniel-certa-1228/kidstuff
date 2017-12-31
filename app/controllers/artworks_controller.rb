require 'rmagick'

class ArtworksController < ApplicationController
    def new
        @artwork = Artwork.new
    end

    def index
        @artworks = Artwork.all.order('created_at DESC')
        # indexed with newest at top
    end

    def create
        begin
            @artwork = Artwork.new(artwork_params)
            if is_photo?(params[:artwork][:avatar].path)
                if @artwork.save
                    redirect_to artworks_path
                else
                    render 'new'
                end
            else
                render 'new'
            end
        rescue NoMethodError => e
            # puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ #{e}"
            flash[:error] = "Please attach an image!"
            redirect_to new_artwork_path
        end
    end

    def edit
        @artwork = Artwork.find(params[:id])
        @children = Child.all
        #children loaded from DB to populate select menu
    end

    def update
        @artwork = Artwork.find(params[:id])
        if @artwork.update(artwork_params)
            redirect_to @artwork
        else
            render 'edit'
        end
    end

    def show
        @artwork = Artwork.find(params[:id])
        # logic to display 'n/a' for blank field
        if @artwork.title.blank?
            @title = "n/a"
        else
            @title = @artwork.title
        end
        # logic to display 'n/a' for blank field
        if @artwork.child_id.blank?
            @child = "n/a"
        else
            @child = Child.where(id: @artwork.child_id)
            @child = @child[0].child_name
        end
        # logic to display 'n/a' for blank field
        if @artwork.date.blank?
            @parsed_date = "n/a"
        else
            @parsed_date = @artwork.date.strftime( '%m/%d/%Y' )
        end
    end

    def destroy
        @artwork = Artwork.find(params[:id])
        @artwork.destroy
        redirect_to artworks_path
    end

    def search
        @search = params[:search_string]
        @artworks= Artwork.fuzzy_title_search(@search)
        render 'search'
    end

    def send_jpg
        @user = User.find(session[:user_id])

        @artwork = Artwork.find(params[:id])
        # logic to display 'n/a' for blank field
        if @artwork.title.blank?
            @title = "n/a"
        else
            @title = @artwork.title
        end
        # logic to display 'n/a' for blank field
        if @artwork.child_id.blank?
            @child = "n/a"
        else
            @child = Child.where(id: @artwork.child_id)
            @child = @child[0].child_name
        end
        # logic to display 'n/a' for blank field
        if @artwork.date.blank?
            @parsed_date = "n/a"
        else
            @parsed_date = @artwork.date.strftime( '%m/%d/%Y' )
        end

        #connect to s3 bucket to get the jpg
        s3 = Aws::S3::Client.new(
            region: ENV.fetch('AWS_REGION'),
            access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
            secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
            )

        @jpeg = s3.get_object(bucket: ENV.fetch('S3_BUCKET_NAME'), key: "artworks/#{@artwork.id}.original.jpg")
        @saved_jpg = Magick::Image.from_blob(@jpeg.body.read)[0]
        #convert from blob to jpeg & save to local disk
        @saved_jpg.write("kidstuff_artwork_#{@artwork.id}.jpg")
    end

    def mail_it
        @email = params[:artwork][:email]
        @user_name = params[:artwork][:user_name]
        @user_email = params[:artwork][:user_email]
        @title = params[:artwork][:title]
        @child = params[:artwork][:child]
        @date = params[:artwork][:date]
        @attachment = "kidstuff_artwork_#{params[:artwork][:attachment_id]}.jpg"
        @artwork_id = params[:artwork][:attachment_id]
        
        if is_valid?(@email)
            ArtMailer.artwork_mail(@email, @user_name, @user_email, @title, @child, @date, @attachment).deliver_later
            redirect_to artworks_path
            sleep 0.5 #half-second delay ensures that the file is still there when the email is sent
            File.delete("#{@attachment}") #file deleted from root level after copy is sent
        else
            redirect_to send_art_path(@artwork_id), notice: 'You must enter a valid email address.'
        end
    end

    private

        def artwork_params
            params.require(:artwork).permit(:title, :date, :avatar, :child_id, :user_id )
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
