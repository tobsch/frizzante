# Requires the Gemfile
require 'bundler'
Bundler.require

require "sinatra/json"
require "sinatra/streaming"
require 'open-uri'
require 'open3'

config = {
  proxyURL: ENV['PROXY_URL'] || 'http://127.0.0.1:4567',
  tunerCount: ENV['TUNER_COUNT'] || 6,
  port: ENV['PORT'] || '4567',
  fritzboxHost: ENV['FRITZBOX_HOST'] || 'fritz.box'
}

configure do
  set :server, :puma
  set :bind, '0.0.0.0'
  set :port, config[:port]
end

discoverData = {
  FriendlyName: 'Frizzante',
  Manufacturer: 'Silicondust',
  ModelNumber: 'HDTC-2US',
  FirmwareName: 'hdhomeruntc_atsc',
  TunerCount: config[:tunerCount].to_i,
  FirmwareVersion: '20150826',
  DeviceID: '12345678',
  DeviceAuth: 'test1234',
  BaseURL: '%s' % config[:proxyURL],
  LineupURL: '%s/lineup.json' % config[:proxyURL]
}

# By default Sinatra will return the string as the response.
get '/discover.json' do
  json discoverData
end

get '/lineup_status.json' do
  json({
      'ScanInProgress': 0.to_s,
      'ScanPossible': 1.to_s,
      'Source': "Cable",
      'SourceList': ['Cable']
  })
end

def get_channels(replace_urls = true, config)
  urls = [ "http://#{config[:fritzboxHost]}/dvb/m3u/tvhd.m3u", "http://#{config[:fritzboxHost]}/dvb/m3u/tvsd.m3u" ]
  channels = []

  urls.each do |url|
    open(url).read.split('#EXTINF:0,').each do |raw|
      next unless url = raw.match(/(rtsp:.*?)$/)
      channel_id = (channels.size + 1)
      channels << {
        GuideNumber: channel_id.to_s,
        GuideName: raw.lines[0].strip,
        URL: replace_urls ? "#{config[:proxyURL]}/tune-in-#{channel_id}" : url[1]
      }
    end
  end

  channels
end

get '/lineup.json' do
  json get_channels(true, config)
end

get '/tune-in-:channel' do |channel|
  if chan = get_channels(false, config).find { |chan| chan[:GuideNumber] == channel }
    content_type 'video/mpeg'
    cmd = "ffmpeg -i '#{chan[:URL]}' -acodec copy -vcodec copy -f mpegts -"
    puts "opening #{cmd} pipe"
    stream do |out|
      Open3.popen2('ffmpeg', '-i', chan[:URL], '-acodec', 'copy', '-vcodec', 'copy', '-f', 'mpegts', '-') do |stdin, stdout, status_thread|
        stdout.each_line do |line|
          out.write line
          out.flush
        end
        raise "Streaming failed"  unless status_thread.value.success?
      end
    end
  end
end

%i(get post).each do |method|
  send method, '/lineup.post' do
    ''
  end
end

%w(/ /device.xml).each do |path|
  get path do
    content_type 'application/xml'
    @data = discoverData
    erb :device_xml
  end
end
