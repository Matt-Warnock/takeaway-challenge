# frozen_literial_string: true

require 'twilio-ruby'

class TwilioClient
  def initialize
    @client = Twilio::REST::Client.new(ENV['ACCOUNT_SID'], ENV['AUTH_TOKEN'])
  end

  def send_text(message, number = ENV['RECEIVER_NUMBER'])
    response = client.messages.create(
      body: message,
      messaging_service_sid: ENV['MESSAGING_SERVICE_SID'],
      to: number
    )
    confirmation(response, message)
  end

  private

  attr_reader :client

  def confirmation(response, message)
    "#{response.status}: #{message}"
  end
end
