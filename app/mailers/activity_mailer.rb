class ActivityMailer < ApplicationMailer
    def activity_mail(address, user_name, user_email, title, child, date, time, content, attachment)

        attachments["#{attachment}"] = File.read( "#{Rails.root}/#{attachment}" )
        @address = address
        @user_name =  user_name
        @user_email = user_email
        @title = title
        @child = child
        @date = date
        @time = time
        @content = content
        mail(to: @address, subject: "You've received an Activity from #{@user_name} (#{@user_email}) via Kid Stuff App!")
    end
end
