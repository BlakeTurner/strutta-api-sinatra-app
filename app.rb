# Gems
require 'sinatra'
require 'strutta-api'
require 'json'

# Dev only
require 'byebug'

# Allow localhost CORS for easy local deployment
set :protection, false
before do
  content_type :json
  headers 'Access-Control-Allow-Origin' => '*', 'Access-Control-Allow-Methods' => ['OPTIONS', 'POST'], 'Access-Control-Allow-Headers' => 'Origin, X-Requested-With, Content-Type, Accept'
end

# Get your API token from api.strutta.com
# STRUTTA_PRIVATE_TOKEN = 'mystruttaprivatetoken'
# STRUTTA_GAME_ID = ''
STRUTTA_PRIVATE_TOKEN = 'becf267a11366a5b39d8ea9f5a99e63f'
STRUTTA_GAME_ID = 74

# REGISTRATION

# Necessary for localhost CORS
options '/register' do
  200
end

post '/register' do
  # Create participant definition from POST data
  data = JSON.parse request.body.read
  participant_data = {
    email: data['email'],
    metadata: { name: data['name'] }
  }

  # Create participant using Strutta API
  strutta = Strutta::API.new STRUTTA_PRIVATE_TOKEN
  strutta.games(STRUTTA_GAME_ID).participants.create(participant_data).to_json
end

# RENEW PARTICIPANT TOKEN

# Necessary for localhost CORS
options '/renew' do
  200
end

post '/renew' do
  # Create participant definition from POST data
  data = JSON.parse request.body.read

  # Ideally you'd have your user's Strutta Participant ID stored in a DB, but if you don't here's how to get it

  # Get participant by email, renew token if needed
  strutta = Strutta::API.new STRUTTA_PRIVATE_TOKEN
  participant = strutta.games(STRUTTA_GAME_ID).participants.search(email: data['email'])

  if participant['token_expired']
    token = strutta.games(STRUTTA_GAME_ID).participants(participant['id']).token_renew(duration: 60 * 60)
    participant['token'] = token['token']
    participant['token_expired'] = token['token_expired']
    byebug
  end

  participant.to_json
end
