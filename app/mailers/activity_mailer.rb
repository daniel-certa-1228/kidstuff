class ActivityMailer < ApplicationMailer
    def activity_mail(address, user_name, user_email, title, child, date, time, content, attachment, attachment_cal)
        attachments["#{attachment}"] = File.read("#{Rails.root}/tmp/send_pics/#{attachment}")
        if attachment_cal != [] #only attaches ical file if it exists
            attachments["#{attachment_cal}"] = File.read( "#{Rails.root}/tmp/ics_files/#{attachment_cal}" )
        end
        @address = address
        @user_name =  user_name
        @user_email = user_email
        @title = title
        @child = child
        @date = date
        @time = time
        @content = content
        mail(to: @address, reply_to: @user_email, subject: "You've received an Activity from #{@user_email} via Kid Stuff App!")
    end
end
