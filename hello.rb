require 'sinatra'
require 'faker'
require 'concurrent'

require 'rbconfig'

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
    ! defined?(Concurrent::CAtomic).nil?
  end

  ext = ext.value ? 'C extensions are loaded' : 'Pure Ruby, baby!'

  response = HEAD +
    '<h1>' + tagline.value +
    '</h1><p>' + ext + '</p>' +
    '<table border="1">'

  begin
    require 'concurrent/extension'
    response += "<tr><td>C extensions</td><td>loaded</td></tr>"
  rescue LoadError => ex
    response += "<tr><td>C extensions</td><td>#{ex.message}</td></tr>"
  end

  begin
    require 'concurrent_ruby_ext'
    response += "<tr><td>Java extensions</td><td>loaded</td></tr>"
  rescue LoadError => ex
    response += "<tr><td>Java extensions</td><td>#{ex.message}</td></tr>"
  end

  response +=
    '<tr><td>RUBY_VERSION</td><td>' + RUBY_VERSION + '</td></tr>' +
    '<tr><td>RUBY_ENGINE</td><td>' + RUBY_ENGINE + '</td></tr>' +
    '<tr><td>defined?(Concurrent::CAtomic)</td><td>' + defined?(Concurrent::CAtomic).to_s + '</td></tr>' +
    '<tr><td>defined?(Concurrent::CAtomicBoolean)</td><td>' + defined?(Concurrent::CAtomicBoolean).to_s + '</td></tr>'+ 
    '<tr><td>defined?(Concurrent::CAtomicFixnum)</td><td>' + defined?(Concurrent::CAtomicFixnum).to_s + '</td></tr>'

  #RbConfig::CONFIG.each do |key, value|
    #response += '<tr><td>' + key + '</td><td>' + value + '</td></tr>'
  #end

  response += '</table>' + TAIL
  response
end
