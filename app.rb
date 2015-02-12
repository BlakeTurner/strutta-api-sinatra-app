# Gems
require 'sinatra'
require 'strutta-api'
require 'json'

# Rename config_template.rb to config.rb
require_relative 'cors'
require_relative 'config'

# Definition files
require_relative 'definitions/game.rb'
require_relative 'definitions/rounds.rb'

# Dev only
require 'byebug'

# SETUP
get '/setup' do
  erb :setup
end

# CREATE GAME
post '/create-game' do
  strutta = Strutta::API.new STRUTTA_PRIVATE_TOKEN
  strutta.games.create(GAME_DEFINITION).to_json
end

# CREATE ROUNDS
post '/create-rounds' do
  strutta = Strutta::API.new STRUTTA_PRIVATE_TOKEN

  # Create Rounds
  rounds = {
    submission: strutta.games(STRUTTA_GAME_ID).rounds.create(SUBMISSION),
    random_draw: strutta.games(STRUTTA_GAME_ID).rounds.create(RANDOM_DRAW),
    webhook: strutta.games(STRUTTA_GAME_ID).rounds.create(WEBHOOK)
  }

  rounds.to_json
end

# CREATE FLOW
post '/create-flow' do
  content_type :json
  data = JSON.parse request.body.read
  flow_definition = [
    {
      id: data['submission_id'],
      pass_round: data['random_draw_id'],
      start: true
    },
    {
      id: data['random_draw_id'],
      pass_round: data['webhook_id']
    },
    {
      id: data['webhook_id']
    }
  ]
  strutta = Strutta::API.new STRUTTA_PRIVATE_TOKEN
  strutta.games(STRUTTA_GAME_ID).flow.create(definition: flow_definition).to_json
end

# CREATE STRUTTA PARTICIPANT
post '/register' do
  content_type :json

  # Create participant definition from POST data
  data = JSON.parse request.body.read
  participant_data = {
    email: data['email'],
    metadata: { name: data['name'] }
  }

  begin
    # Create participant using Strutta API
    strutta = Strutta::API.new STRUTTA_PRIVATE_TOKEN
    strutta.games(STRUTTA_GAME_ID).participants.create(participant_data).to_json

  rescue Strutta::Errors::UnprocessableEntityError => message
    status 422
    { message: 'There is already a Participant with this email address, please Sign In instead' }.to_json
  end
end

# RENEW PARTICIPANT TOKEN
post '/renew' do
  content_type :json

  # Create participant definition from POST data
  data = JSON.parse request.body.read

  # Ideally you'd have your user's Strutta Participant ID stored in a DB, but if you don't here's how to get it

  # Get participant by email
  strutta = Strutta::API.new STRUTTA_PRIVATE_TOKEN
  participant = strutta.games(STRUTTA_GAME_ID).participants.search(email: data['email'])

  # Renew token if needed
  if participant['token_expired']
    token = strutta.games(STRUTTA_GAME_ID).participants(participant['id']).token_renew(duration: 60 * 60)
    participant['token'] = token['token']
    participant['token_expired'] = token['token_expired']
  end

  participant.to_json
end
