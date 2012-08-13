# This runs a simple sinatra app as a service

LOG_FILE = 'C:\\test.log'
WEB_LOG = 'C:\\thin-server.log'


require "rubygems"
require 'sinatra/base'

# create sinatra app
class MySinatraApp < Sinatra::Base
	get '/' do
    'Hello world!'
	end	
end

begin
  require 'win32/daemon'
  include Win32

  #Windows discards a services console output, so send it to a log instead
  $stdout.reopen(WEB_LOG, "a")
  $stderr.reopen($stdout)
  $stdout.sync = true

  class DemoDaemon < Daemon
    def service_main
      MySinatraApp.run! :host => 'localhost', :port => 9090, :server => 'thin'
      while running?
        sleep 10
        File.open(LOG_FILE, "a"){ |f| f.puts "Service is running #{Time.now}" } 
      end
    end 

    def service_stop
      File.open(LOG_FILE, "a"){ |f| f.puts "***Service stopped #{Time.now}" }
      exit! 
    end
  end

  DemoDaemon.mainloop
rescue Exception => err
  File.open(LOG_FILE,'a+'){ |f| f.puts " ***Daemon failure #{Time.now} err=#{err} " }
  raise
end
