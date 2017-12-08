require 'ocr_space'
# require 'rmagick'
require "mini_magick"

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
        @artwork= Artwork.fuzzy_title_search(@search)
        render 'search'
    end

    def send_jpg
        @artwork = Artwork.find(params[:id])

        s3 = Aws::S3::Client.new(
            region: ENV.fetch('AWS_REGION'),
            access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
            secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
          )

        @jpeg = s3.get_object(bucket: ENV.fetch('S3_BUCKET_NAME'), key: "artworks/#{@artwork.id}.original.JPG")
        @jpeg.write("kidstuff_artwork_#{@artwork.id}.jpg")
        # @new_pdf = Magick::Image.from_blob(@jpeg.body.read)[0]
        # @new_pdf.write("kidstuff_assignment_#{@assignment.id}.pdf")
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

    # def to_text
    #     image = MiniMagick::Image.new(params[:assignment][:avatar].path)
    #     image = image.resize "1200x1800"
    #     resource = OcrSpace::Resource.new(apikey: ENV.fetch('OCR_API_KEY'))
    #     @assignment.content = resource.clean_convert file: image.path
    # end
end
