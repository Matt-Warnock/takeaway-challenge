# frozen_literial_string: true

require 'twilio-ruby'

class TwilioClient
  def send_text(message)
    account_sid = ENV['ACCOUNT_SID']
    auth_token = ENV['AUTH_TOKEN']

    @client = Twilio::REST::Client.new(account_sid, auth_token)

    response = @client.messages.create(
      body: message,
      messaging_service_sid: ENV['MESSAGING_SERVICE_SID'],
      to: ENV['RECEIVER_NUMBER']
    )
    "#{response.status}: #{message}"
  end
end
