class AssignmentMailer < ApplicationMailer

    def assignment_mail(address, user_name, user_email, title, child, due_date, content, attachment, attachment_cal)                                            
        attachments["#{attachment}"] = File.read("#{Rails.root}/tmp/send_pics/#{attachment}")
        if attachment_cal != [] #only attaches ical file if it exists
            attachments["#{attachment_cal}"] = File.read( "#{Rails.root}/tmp/ics_files/#{attachment_cal}" )
        end
        @user_name =  user_name
        @user_email = user_email
        @address = address
        @title = title
        @child = child
        @due_date = due_date
        @content = content
        mail(to: @address, reply_to: @user_email, subject: "You've received an Assignment from #{@user_email} via Kid Stuff App!")
    end

end
