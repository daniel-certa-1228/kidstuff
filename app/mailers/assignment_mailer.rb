class AssignmentMailer < ApplicationMailer

    def assignment_mail(address, user_name, user_email, title, child, due_date, content, attachment)                                            
        attachments["#{attachment}"] = File.read( "#{Rails.root}/#{attachment}" )
        @user_name =  user_name
        @user_email = user_email
        @address = address
        @title = title
        @child = child
        @due_date = due_date
        @content = content
        mail(to: @address, subject: "You've received an Assignment from #{@user_name} (#{@user_email}) via Kid Stuff App!")
    end

end
