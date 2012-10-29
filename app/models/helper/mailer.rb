require 'rubygems'
require 'tlsmail'

module Helper

  class Mailer

    def self.send_pw_reset_mail_to(to,contents)

      from = 'itemmarket.mail@gmail.com'
      pw = 'itemmarket123'

      content = <<EOF
                From: #{from}
                To: #{to}
                subject: "Item|Market PW Reset"
                Date: #{Time.now.rfc2822}

                #{contents}

                Regards,
                  Your item|market - Team
EOF

      Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
      Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', from, pw, :login) do |smtp|
        smtp.send_message(content, from, to)
      end
    end

    def self.send_verification_mail_to(to,contents)

      from = 'itemmarket.mail@gmail.com'
      pw = 'itemmarket123'

      content = <<EOF
From: #{from}
To: #{to}
subject: "Item|Market Register Verification"
Date: #{Time.now.rfc2822}

      #{contents}

Regards,
Your item|market - Team
EOF

      Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
      Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', from, pw, :login) do |smtp|
        smtp.send_message(content, from, to)
      end
    end




  end
end