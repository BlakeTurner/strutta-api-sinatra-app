# Add routes necessarily for local development CORS
set :protection, false
before do
  content_type :json
  headers 'Access-Control-Allow-Origin' => '*', 'Access-Control-Allow-Methods' => ['OPTIONS', 'POST'], 'Access-Control-Allow-Headers' => 'Origin, X-Requested-With, Content-Type, Accept'
end

# Necessary for localhost CORS
options '/register' do
  200
end

# Necessary for localhost CORS
options '/renew' do
  200
end
