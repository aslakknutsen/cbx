require "vertx"


appConfig = {
    :frontend => {
        # Config for verticle1
    },
    :lanyrd => {
        # Config for verticle2
    }
}

puts "Starting backend.."
Vertx.deploy_worker_verticle('lanyrd_handler.rb', appConfig[:lanyrd]) {
	puts "Starting frontend.."
	Vertx.deploy_verticle('server.rb', appConfig[:frontend])
}


