require "json"
require "vertx"
include Vertx

#@lanyrd   = Lanyrd::Client.new
@client = Vertx::HttpClient.new
@client.host = "lanyrd.com"

@handlers = []

@handlers << Vertx::EventBus.register_handler('lanyrd.event') do |message|
    slug = message.body
    puts "Lanyrd event request for #{slug}"
	
	get("#{Time.now.year}/#{slug}/") {|json|
		message.reply JSON.pretty_generate json
	}
end

@handlers << Vertx::EventBus.register_handler('lanyrd.event.search') do |message|
    slug = message.body
    puts "Lanyrd event search request for #{slug}"
    get("search/?q=#{slug}") {|json|
    	message.reply JSON.pretty_generate json['sections'][0]['rows']
    }
end

@handlers << Vertx::EventBus.register_handler('lanyrd.event.people') do |message|
	slug = message.body
    puts "Lanyrd event people request for #{slug}"
    get("#{Time.now.year}/#{slug}/speakers/") {|speakers_json|
    	speakers = get_rows(speakers_json['sections'])
	    get("#{Time.now.year}/#{slug}/attendees/") {|attendees_json|
			attendees = get_rows(attendees_json['sections'])
			message.reply JSON.pretty_generate( filter_twitter_users(speakers + attendees))
		}
    }
end

def vertx_stop
  @handlers.each {| id |
	Vertx::EventBus.unregister_handler(id)
  }
end

def get(path, &block)
	request = @client.get("/mobile/ios2/#{path}") do |res|
		res.body_handler do |body|
			block.call JSON.parse body.to_s
		end
	end
	request.headers['X-Lanyrd-Auth'] = Time.now.hash.to_s
	request.headers['User-Agent'] = "Lanyrd-iOS/2.4.0 (iPhone OS 6.1.3; iPhone5,2 N42AP) build/61"
	request.headers['X-Lanyrd-Protocol'] = "4"
	request.headers['X-Lanyrd-Hardware'] = "320x568@2"
	request.headers['X-Lanyrd-DeviceID'] = "Device-String"
	request.headers['X-Lanyrd-PushEnvironment'] = "ios-production"
	request.headers['x-mycustomurl-intercept'] = "api"
	request.end
end

def get_rows(section_list)
	rows = []
	section_list.each {|s| rows.concat(s["rows"])}
	rows
end

def filter_twitter_users(people)
	#return people
	people.select do |p|
			if p['profile_links'].nil?
				false
			elsif p['profile_links'].select{|a| "twitter".eql? a['icon_class']}.size == 0
				false
			else
				true
			end
	end.map do |p|
		  	person = {}
		  	twitter_id = p['profile_links'].find{|a|"twitter".eql? a['icon_class']}['url']
		  	if twitter_id =~ /.*\/(.*)/
		  		twitter_id = $1
		  	end
		  	person[:twitter_id] = twitter_id
		  	person[:image] = p['image']
		  	person[:name] = p['title']
		  	person
	end
end