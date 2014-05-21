require "vertx"
include Vertx

@server = Vertx::HttpServer.new

route_matcher = Vertx::RouteMatcher.new

route_matcher.get('/') do |req|
	req.response.end("main")
end

route_matcher.get('/api/event/search/:slug') do |req|
	slug = req.params[:slug]
	puts "Received request for event search #{slug}"
    Vertx::EventBus.send('lanyrd.event.search', slug) {|m|
    	json_response req, m
    }
end

route_matcher.get('/api/event/:slug') do |req|
	slug = req.params[:slug]
	puts "Received request for event #{slug}"
    Vertx::EventBus.send('lanyrd.event', slug) {|m|
    	json_response req, m
    }
end

route_matcher.get('/api/event/:slug/people') do |req|
	slug = req.params[:slug]
	puts "Received request for event people #{slug}"
    Vertx::EventBus.send('lanyrd.event.people', slug) {|m|
    	json_response req, m
    }
end

def json_response(request, message)
	request.response.status_code = 200
	request.response.headers['Content-Type'] = "application/json"
	request.response.end message.body
end

@server.request_handler(route_matcher).listen(8080, 'localhost')

def vertx_stop
  @server.close
end
