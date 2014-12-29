require 'sinatra'
require 'faker'
require 'concurrent'

HEAD = <<-HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
    "http://www.w3.org/TR/html4/strict.dtd">
<html lang="en">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Testing Concurrent Ruby on Heroku</title>
  </head>
  <body>
HTML

TAIL = <<-HTML
  </body>
</html>
HTML

get '/' do

  tagline = Concurrent::Future.execute do
    Faker::Company.catch_phrase + ' to ' + Faker::Company.bs + '.'
  end

  ext = Concurrent::Future.execute do
    'constant' == defined?(Concurrent::CAtomic)
  end

  ext = ext.value ? 'C extensions are loaded' : 'Pure Ruby, baby!'

  HEAD + '<h1>' + tagline.value + '</h1><p>' + ext + '</p>' + TAIL
end
