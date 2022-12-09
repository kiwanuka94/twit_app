class Feedback < ApplicationRecord

  #1. user creates a feedback record
  #2. tweet the text attribute of the feedback record, to the recipient handle attribute

  after_create :send_tweet

  def send_tweet
    puts "Sending tweet!"
    #ToDo => insert twitter api logic here.
  end
end
