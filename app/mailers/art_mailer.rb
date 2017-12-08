class ArtMailer < ApplicationMailer
    def artwork_mail(address, title, date, attachment)
        attachments["#{attachment}"] = File.read( "#{Rails.root}/#{attachment}" )
        @address = address
        @title = title
        @date = date
        mail(to: @address, subject: "You've received Art from Kidstuff!")
    end
end
