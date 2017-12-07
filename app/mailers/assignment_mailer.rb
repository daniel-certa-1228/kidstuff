class AssignmentMailer < ApplicationMailer

    def assignment_mail(address, title, due_date, content, attachment)                                            #the file needs an extra ../ on Heroku 
        attachments["#{attachment}"] = File.read( "#{Rails.root}/#{attachment}" )
        @address = address
        @title = title
        @due_date = due_date
        @content = content
        mail(to: @address, subject: "You've received an Assignment from Kidstuff!")
    end

end
