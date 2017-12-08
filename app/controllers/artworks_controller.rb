require 'ocr_space'
require 'rmagick'

class ArtworksController < ApplicationController
    def new
        @artwork = Artwork.new
    end

    def index
        @artworks = Artwork.all
    end

    def create
        @artwork = Artwork.new(artwork_params)
        if @artwork.save
            redirect_to artworks_path
        else
            render 'new'
        end
    end

    def edit
        @artwork = Artwork.find(params[:id])
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
        @artwork = Artwork.find(params[:id])

        s3 = Aws::S3::Client.new(
            region: ENV.fetch('AWS_REGION'),
            access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
            secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
          )

        @jpeg = s3.get_object(bucket: ENV.fetch('S3_BUCKET_NAME'), key: "artworks/#{@artwork.id}.original.jpg")
        # @jpeg.write("kidstuff_artwork_#{@artwork.id}.jpg")
        @saved_jpg = Magick::Image.from_blob(@jpeg.body.read)[0]
        @saved_jpg.write("kidstuff_artwork_#{@artwork.id}.jpg")
    end

    def mail_it
        @email = params[:artwork][:email]
        @title = params[:artwork][:title]
        @date = params[:artwork][:due_date]
        @attachment = "kidstuff_artwork_#{params[:artwork][:attachment_id]}.jpg"
        ArtMailer.artwork_mail(@email, @title, @date, @attachment).deliver_later
        redirect_to artworks_path
        File.delete("#{@attachment}")
    end

    private
    def artwork_params
        params.require(:artwork).permit(:title, :date, :avatar, :child_id, :user_id )
    end
end
