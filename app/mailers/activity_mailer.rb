class ActivityMailer < ApplicationMailer
    def activity_mail(address, title, date, time, content, attachment)
                                                        #the file needs an extra ../ on Heroku 
        attachments["#{attachment}.pdf"] = File.read( "#{Rails.root}/#{attachment}.pdf")
        @address = address
        @title = title
        @date = date
        @time = time
        @content = content
        mail(to: @address, subject: "You've received an Activity from Kidstuff!")
    end
end
