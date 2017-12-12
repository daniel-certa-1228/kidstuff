class ActivityMailer < ApplicationMailer
    def activity_mail(address, title, child, date, time, content, attachment)
                                                        #the file needs an extra ../ on Heroku 
        attachments["#{attachment}"] = File.read( "#{Rails.root}/#{attachment}" )
        @address = address
        @title = title
        @child = child
        @date = date
        @time = time
        @content = content
        mail(to: @address, subject: "You've received an Activity from Kidstuff!")
    end
end
