# Kid Stuff

### Kid Stuff is __LIVE__ and optimized for __mobile browsing__, so grab your smartphone and go to [https://kidstuffapp.herokuapp.com/](https://kidstuffapp.herokuapp.com/).

Kid Stuff is an organizational tool that utilizes __Optical Character Recognition__ (via [OCR Space API](https://ocr.space/)) to help keep track of a child's Art Projects, Homework, and Extra-Curricular Activities.

![Screen Shot 1](https://s3.us-east-2.amazonaws.com/kidstuffapp/screenshots/IMG_0778-a.png "Screen Shot 1")
![Screen Shot 2](https://s3.us-east-2.amazonaws.com/kidstuffapp/screenshots/IMG_0779-a.png "Screen Shot 2")
![Screen Shot 3](https://s3.us-east-2.amazonaws.com/kidstuffapp/screenshots/IMG_0781-a.png "Screen Shot 3")

### Use your mobile device's camera to scan in Homework or Activity documents- Kid Stuff reads them using OCR and makes them _instantly searchable by content_.

![Screen Shot 4](https://s3.us-east-2.amazonaws.com/kidstuffapp/screenshots/IMG_0780-a.png "Screen Shot 4")
![Screen Shot 5](https://s3.us-east-2.amazonaws.com/kidstuffapp/screenshots/IMG_0786-a.png "Screen Shot 5")
![Screen Shot 6](https://s3.us-east-2.amazonaws.com/kidstuffapp/screenshots/IMG_0783-a.png "Screen Shot 6")

### Kid Stuff events can be saved directly to iCal and documents can be emailed as PFD's.

![Screen Shot 7](https://s3.us-east-2.amazonaws.com/kidstuffapp/screenshots/ksa_mail.png "Screen Shot 7")

### Dependencies-
* Ruby 2.4.2
* Rails 5.1.4
* Bootstrap 4.0.0.beta2
* PostgreSQL 0.18
* AWS s3
* [OCR Space API](https://ocr.space/) 
* icalendar
* paperclip
* imagemagick 0.1.3
* rmagick 2.15
* mini_magick

### To Run-

1. Fork/clone this repo and `cd` into the root directory.
1. Run `bundle install`
1. Run `npm install`
1. Run `rails db:migrate`
1. Run `rails server`
1. Navigate in a browser to `http://localhost:3000` and create a Kid Stuff Account.
