require "vertx"

appConfig = {
    :frontend => {
        # Config for verticle1
    },
    :lanyrd => {
        # Config for verticle2
    },
    :neo => {
        # Config for verticle2
    }
}

puts "Starting backend.."
Vertx.deploy_module('org.cbx~cbx-backend~1.0', appConfig[:neo]);
Vertx.deploy_verticle('lanyrd_handler.rb', appConfig[:lanyrd]) {
    puts "Starting frontend.."
    Vertx.deploy_verticle('server.rb', appConfig[:frontend])
}