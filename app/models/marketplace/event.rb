module Marketplace
  require 'rubygems'
  require 'tlsmail'

  class Event
    attr_accessor :user

    def self.create(user)
      event = self.new
      event.user = user
      event
    end

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

  end
end