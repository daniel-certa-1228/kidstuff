class ArtMailer < ApplicationMailer
    def artwork_mail(address, user_name, user_email, title, child, date, attachment)
        attachments["#{attachment}"] = File.read( "#{Rails.root}/#{attachment}" )
        @user_name =  user_name
        @user_email = user_email
        @address = address
        @child = child
        @title = title
        @date = date
        mail(to: @address, subject: "You've received Art from #{@user_name} (#{@user_email}) via Kid Stuff App!")
    end
end
