require 'ocr_space'
require 'rmagick'
require "mini_magick"

class ActivitiesController < ApplicationController
    # def index
    #     @activities = Activity.all
    # end

    # def create
    #     @doc = Activity.new(doc_params)
    #     to_text
    #     if @doc.save
    #         redirect_to docs_path
    #     else
    #         render 'new'
    #     end
    # end

    # def update
    #     @doc = Activity.find(params[:id])
    #     if @doc.update(customer_params)
    #         redirect_to @doc
    #     else
    #         render 'edit'
    #     end
    # end

    # def show
    #     @doc = Activity.find(params[:id])
    # end

    # def destroy
    #     @doc = Activity.find(params[:id])
    #     @doc.destroy
    #     redirect_to root_path
    # end

    # def search
    #     @search = params[:search_string]
    #     @docs = Activity.fuzzy_content_search(@search)
    #     render 'search'
    # end

    # def send_pdf
    #     @doc = Activity.find(params[:id])

    #     s3 = Aws::S3::Client.new(
    #         region: ENV.fetch('AWS_REGION'),
    #         access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
    #         secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
    #       )

    #     @jpeg = s3.get_object(bucket: ENV.fetch('S3_BUCKET_NAME'), key: "docs/#{@doc.id}.original.JPG")
    #     @new_pdf = Magick::Image.from_blob(@jpeg.body.read)[0]
    #     @new_pdf.write("#{@doc.description}.pdf")
        
    # end

    # def mail_it
    #     @email = params[:doc][:email]
    #     @description = params[:doc][:description]
    #     @content = params[:doc][:content]
    #     @attachment = params[:doc][:description]
    #     ActivityMailer.activity_mail(@email, @description, @content, @attachment).deliver_later
    #     redirect_to docs_path
    #     File.delete("#{@attachment}.pdf")
    # end

    # private
    # def doc_params
    #     params.require(:activity).permit(:description, :date, :time, :content, :avatar, :user_id )
    # end

    # def to_text
    #     image = MiniMagick::Image.new(params[:activity][:avatar].path)
    #     image = image.resize "1200x1800"
    #     resource = OcrSpace::Resource.new(apikey: "0cf421d36788957")
    #     @doc.content = resource.clean_convert file: image.path
    # end
end
