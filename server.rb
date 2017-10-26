# coding: utf-8
require 'sinatra'
require 'json'
require 'active_support'
require 'active_support/core_ext'
require './process.rb'

set :bind, '0.0.0.0'
set :port, 3001

get '/pingtest' do
  if params['id'].nil? then
    result = {error: "parameter 'id' is required"}
    code = 400
  else
    result = CucumberProcess.find(params['id'].to_i)
    if result.nil?
      code = 404
    elsif result.stderr.present?
      code = 503
    else
      code = 200
    end
  end
  status code
  if code == 200
    body result.to_json
  end
end

post '/pingtest', provides: :json do
  params = JSON.parse request.body.read
  process = CucumberProcess.new()
  command = "pingtest " + params['vlan_id'] + " " + params['sites'].join(" ")
  if !params['dry-run'].nil? && params['dry-run'].to_i != 0
    command = command + " DRY"
  end
  process.exec(command)
  status 200
  body process.to_json
end
