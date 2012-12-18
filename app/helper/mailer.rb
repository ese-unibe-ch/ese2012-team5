# Module that sends all marketplace related emails. Each kind of email has its own method.
module Mailer

  @database = Marketplace::Database.instance

  #itemmarket email address and password
  @from = 'itemmarket.mail@gmail.com'
  @pw = 'itemmarket123'

  # Send a reset password mail with hash to given user
  # @param [User] user
  def self.send_pw_reset_mail(user)
    # Generate hash(24 digits in hex) and timestamp
    hash = SecureRandom.hex(24)
    # Set it valid for 24 hours
    timestamp = Time.new
    valid_until = timestamp + 86400

    @database.add_pw_reset(hash, user, timestamp)

    to = user.email
    content = <<EOF
From: #{@from}
To: #{to}
subject: "Item|Market PW Reset"
Date: #{Time.now.rfc2822}

Hi, #{user.name}
follow this link to reset your password.
http://localhost:4567/reset_password/#{hash}
This link is valid until #{valid_until}

Regards,
Your item|market - Team
EOF

    Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
    Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', @from, @pw, :login) do |smtp|
      smtp.send_message(content, @from, to)
    end
  end

  # Send a verification mail with hash to given user
  # @param [User] user
  def self.send_verification_mail(user)
    hash = SecureRandom.hex(24)
    timestamp = Time.new

    @database.add_verification(hash, user, timestamp)

    to = user.email
    content = <<EOF
From: #{@from}
To: #{to}
subject: "Item|Market Register Verification"
Date: #{Time.now.rfc2822}

Hi, #{user.name}
follow this link to verify your account.
http://localhost:4567/verify_account/#{hash}

Regards,
Your item|market - Team
EOF

    Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
    Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', @from, @pw, :login) do |smtp|
      smtp.send_message(content, @from, to)
    end
  end


end