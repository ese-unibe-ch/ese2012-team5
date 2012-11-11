module Helper
  class NullMailer
    def self.send(msg, rcpt)
      nil
    end
  end
end