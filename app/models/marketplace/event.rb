module Marketplace
  require 'rubygems'
  require 'tlsmail'

  #class of events, takes care of verification and password changing processes, both via email with generated link
  class Event
    attr_accessor :user

    def self.create(user)
      event = self.new
      event.user = user
      event
    end

    #sends a verification email to the event's user from the item markets email acc
    #todo mail must contain a link that when clicked, leads to a controller that sets the attribute 'verified' of the user from false to true
    def send_verification_mail
      acc = 'itemmarketemailclient@gmail.com'
      pw = 'itemmarket101'
      recipient = self.user
      email = recipient.email

      content = <<EOF
Hier sollte nun ein Verifizierungs-Link generiert werden!
EOF

      Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
      Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', acc, pw, :login) do |smtp|
        smtp.send_message(content, acc, email)
      end
    end

    #sends a pw to the user that let's him log in without entering his forgotten password. temp pw should only be valid 24h.
    #todo mail must contain a temp pw that when clicked, leads to a controller that logs in the user and prompts him to change pw immediately
    def send_temp_pw_mail
      acc = 'itemmarketemailclient@gmail.com'
      pw = 'itemmarket101'
      recipient = self.user
      email = recipient.email

      content = <<EOF
Hier sollte nun ein temporäres Passwort verschickt werden
EOF

      Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
      Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', acc, pw, :login) do |smtp|
        smtp.send_message(content, acc, email)
      end
    end

  end
end