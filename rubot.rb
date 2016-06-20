# frozen_string_literal: true

require 'sinatra'
require 'discordrb'
require 'json'

module RubotHandlers; end

$handlers = {}

# Method to load handlers
def deploy!
  # Load all the module code files.
  Dir.glob('handlers/*.rb') { |mod| load mod }

  RubotHandlers.constants.each do |name|
    const = RubotHandlers.const_get name
    if const.is_a? Module
      $handlers[name.to_s.downcase] = const
    end
  end
end

deploy!

# Read the file of existing links so we don't have to re-add everything all the time
$links = JSON.parse(File.read('rubot-links'))

# Reads config
$config = JSON.parse(File.read('config.json'))

token, app_id = File.read('rubot-auth').lines
bot = Discordrb::Bot.new token: token, application_id: app_id.to_i
puts bot.invite_url

bot.message(starting_with: 'rubot, link this:') do |event|
  name = event.content.split(':')[1].strip
  $links[name] ||= []
  $links[name] << event.channel.id
  File.write('rubot-links', $links.to_json)
  event.respond "Linked repo #{name} to #{event.channel.mention} (`#{event.channel.id}`)"
end

bot.message(starting_with: 'rubot, reload handlers') do |event|
  deploy!
  event.respond("Loaded #{$handlers.length} handlers")
end

bot.message(starting_with: 'rubot, eval:') do |event|
  if event.user.id == 66237334693085184 # Replace this ID with yours if you want to do eval
    _, *stuff = event.content.split(':')
    event.respond(eval(stuff.join(':')))
  else
    event.respond('To quote the great Hlaaftana:
  *You cannot use this command. Want to know why?
  This command evaluates actual Groovy code, giving you
  access to my entire computer file system and networking.
  You could delete system32, download gigabytes of illegal porn
  and delete all my files. If you think this is unfair, write your own bot, idiot.*
Now this is not 100% correct, as the command evaluates Ruby code, not Groovy, and runs on Linux without a system32 folder, but you get the gist of it.')
  end
end

bot.run :async

class WSPayload
  attr_reader :data

  def initialize(payload)
    @data = payload
  end

  def repo_name
    @data['repository']['full_name']
  end

  def sender_name
    @data['sender']['login']
  end

  def issue
    @data['issue']
  end

  def pull_request
    @data['pull_request']
  end

  def tiny_issue
    "**##{issue['number']}** (" + %(**#{issue['title']}**) + issue['labels'].map { |e| " `[#{e['name']}]`"}.join + ')'
  end

  def tiny_pull_request
    "**##{pull_request['number']}** (" + %(**#{pull_request['title']}**) + ')'
  end

  def action
    @data['action']
  end

  def [](key)
    @data[key]
  end
end

def handle(event_type, payload)
  event_type = event_type.delete('_')
  payload = WSPayload.new(payload)
  if $handlers[event_type]
    $handlers[event_type].handle(payload)
  else
    nil
  end
end

# This isn't as perfect but gets whatever done.
def check_config(event_type, payload)
  event_type = event_type.delete('_')
  payload = WSPayload.new(payload)
  if $config["showclosed"]
    case payload.action
    when "closed"
      return false
    when "unlabeled"
      return false 
    when "unassigned"
      return false
    end
  end
  {
    "showprs" => "pull_request",
    "showcomments" => "issue_comment",
    "showcommits" => "push",
    "showissues" => "issues",
    "showstars" => "watch",
    "showforks" => "fork"
  }.each do |config_type, event_name|
    if not $config[config_type] and event_type = event_name
      return false
    end
  end
  return true
end

get '/webhook' do
  "Hooray! The bot works. #{$links.length} links are currently registered."
end

post '/webhook' do
  request.body.rewind
  event_type = request.env['HTTP_X_GITHUB_EVENT'] # The event type is a custom request header
  payload = JSON.parse(request.body.read)
  repo_name = payload['repository']['full_name']

  channels = $links[repo_name]
  channels.each do |e|
    response = handle(event_type, payload)
    if check_config(event_type, payload)
      if response
        bot.send_message(e, "**#{repo_name}**: **#{payload['sender']['login']}** " + response)
      else
        puts %(Got a "#{event_type}" event for repo #{repo_name} that is not supported - ignoring)
      end
    end
  end

  204
end
