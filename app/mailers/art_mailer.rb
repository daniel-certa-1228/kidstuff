class ArtMailer < ApplicationMailer
    def artwork_mail(address, title, child, date, attachment)
        attachments["#{attachment}"] = File.read( "#{Rails.root}/#{attachment}" )
        @address = address
        @child = child
        @title = title
        @date = date
        mail(to: @address, subject: "You've received Art from Kidstuff!")
    end
end
