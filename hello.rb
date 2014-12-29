require 'sinatra'
require 'faker'
require 'concurrent'

get '/' do
  response = Concurrent::Future.execute do
    Faker::Company.catch_phrase + ' to ' + Faker::Company.bs + '.'
  end
  response.value
end
