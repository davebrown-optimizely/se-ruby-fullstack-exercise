require 'sinatra'
require 'httparty'
require 'securerandom'
require 'twilio-ruby'
require 'optimizely'

# STEP 1: Add the Optimizely Full Stack Ruby gem
# STEP 2: Require the Optimizely gem 
# STEP 3: Include the twilio account SID, auth token and phone number below

# => Log into Twilio and access the account SID, token, and number
TWILIO_NUMBER = '+19499450560'


# Optimizely Setup

# Step 4: Replace this url with your own Optimizely Project

DATAFILE_URL = 'https://cdn.optimizely.com/public/8367220379/s/10712193766_10712193766.json'

DATAFILE_URI_ENCODED = URI(DATAFILE_URL)
datafile = HTTParty.get(DATAFILE_URL).body
puts datafile
optimizely_client = Optimizely::Project.new(datafile)

# => Step 5: Use a library, such as HTTParty, to get grab the datafile from the CDN
#         https://github.com/jnunemaker/httparty#examples
#         example: response = HTTParty.get('http://api.stackexchange.com/2.2/questions?site=stackoverflow').body
#         The above line will return the body of the http request 
#         NOTE: use the uri encoded url shown above :)

# => Step 6: Initialize the Optimizely SDK using the json retrieved from step 4
#		  https://developers.optimizely.com/x/solutions/sdks/reference/?language=ruby

# => Initializing the Twilio client to send sms messages
# => https://www.twilio.com/docs/libraries/ruby
TWILIO_CLIENT = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN

get '/' do
  puts "[CONSOLE LOG]"
	'Welcome to the SE Full Stack training'
end

# => GET endpoint to receive messages, this should be setup as a webhook in Twilio
# => anytime twilio receives a message on our number, Twilio will make a request to this endpoint 
get '/sms' do
  
  # => Getting the number that texted the sms service
	sender_number = params[:From]
  
  # => Getting the message that was sent to the service
  # => We could use this to understand what the user said, and create a conversational dialog
	text_body = params[:Body]
    
  # => Outputing the number and text body to the ruby console
  # =>	puts "[CONSOLE LOG] New message from #{sender_number}"
  # =>	puts "[CONSOLE LOG] They said #{text_body}"
  # =>	puts "[CONSOLE LOG] Let's respond!"

	# =>  Randomly generate a new User ID to demonstrate bucketing
	# =>  Alternatively, you can use sender_number as the user ID, however due to deterministic bucketing using a single user id will always return the same variation
	user_id = SecureRandom.uuid

	# => STEP 7: Implement an Optimizely Full Stack experiment, or feature flag (with variables)
	# => Example, test out different messages in your response
	# => Using the helper function to reply to the number who messaged the sms service
  # => example: send_sms "Hey this is a response!" sender_number
  # => Optimizely code
  variation_key = optimizely_client.activate('Eng_french', user_id)
  if variation_key == 'English'
      puts "[CONSOLE LOG] New message from #{sender_number}"
      puts "[CONSOLE LOG] They said #{text_body}"
      puts "[CONSOLE LOG] Let's respond!"
      elsif variation_key == 'French'
      puts "[CONSOLE LOG] Nouveau message de #{sender_number}"
      puts "[CONSOLE LOG] Ils ont dit #{text_body}"
      puts "[CONSOLE LOG] Répondons!"
      else
      puts "[CONSOLE LOG] New Message from #{sender_number}"
      puts "[CONSOLE LOG] Unbucketed said #{text_body}"
      puts "[CONSOLE LOG] User ID #{user_id}"
      puts "[CONSOLE LOG] Let's respond!"
  end

end

# => BONUS: Implement a Optimizely webhooks to receive updates when your datafile changes & reinitialize the SDK

# =>  Helper function to send a text message
# =>  The first parameter is the content of the text you wish to send
# =>  The second parameter is the number you wish to send the text to
def send_sms body, number
	TWILIO_CLIENT.api.account.messages.create(
      from: TWILIO_NUMBER,
      to: number,
      body: body
    ) 
end

