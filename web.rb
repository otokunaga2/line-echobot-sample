require 'sinatra'   # gem 'sinatra'
require 'line/bot'  # gem 'line-bot-api'
require 'json'
require 'logger'
logger = Logger.new(STDOUT)
def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
  end
get '/callback' do
  puts "success"
end

post '/callback' do
  body = request.body.read
  puts "body debugging"
  puts body
  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  begin
  logger.debug("events body=#{events.first}") 
  rescue => e
    logger.warn(e)
  end
  begin
  logger.debug("events body=#{events.type.to_s}") 
  rescue => e
    logger.warn(e)
  end
  begin
  logger.debug("events body=#{events.message.type.to_s}") 
  rescue => e
    logger.warn(e)
  end
  events.each { |event|
    case event.type.to_s
    when "message"
      case event.message.type.to_s
      when "text"
        logger.debug("event type checking #{event.type.to_s}")
        message = {
          type: 'text',
          text: event.message['text']
        }
        begin
          client.reply_message(event['replyToken'], message)
        rescue => e
          puts e
        end
      end
    end
  }

  puts "OK"
end
