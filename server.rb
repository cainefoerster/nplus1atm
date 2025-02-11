require 'dotenv/load'
require 'sinatra'
require 'stripe'

# Stripe API-Key wird aus der Umgebungsvariable geladen.
# Auf Render definierst du in den Service‑Settings eine Variable namens STRIPE_SECRET_KEY.
Stripe.api_key = ENV['STRIPE_SECRET_KEY']

set :root, File.dirname(__FILE__)
set :public_folder, -> { File.join(root, 'public') }
set :static, true
set :port, 4242

# Optional: Standort (Location) anlegen – falls benötigt
def create_location
  Stripe::Terminal::Location.create({
    display_name: 'HQ',
    address: {
      line1: 'Stresemannstraße 123',
      city: 'Berlin',
      country: 'DE',
      postal_code: '10963',
    }
  })
end

get '/' do
  redirect '/index.html'
end

post '/connection_token' do
  begin
    token = Stripe::Terminal::ConnectionToken.create
    content_type :json
    { secret: token.secret }.to_json
  rescue => e
    status 500
    e.message
  end
end

post '/capture_payment_intent' do
  request_payload = JSON.parse(request.body.read)
  payment_intent_id = request_payload["payment_intent_id"]
  begin
    intent = Stripe::PaymentIntent.capture(payment_intent_id)
    status 200
  rescue => e
    status 402
    e.message
  end
end
