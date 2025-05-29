require "rack"
require "./functions/api_protected"

class ApiApp
  def call(env)
    request = Rack::Request.new(env)

    if request.path == "/api/protected"
      auth_header = request.env["HTTP_AUTHORIZATION"]
      token = auth_header&.split(" ")&.last

      if token != "123456"
        return [
          401, 
          { "Content-Type" => "application/json" },
          [JSON.generate({ error: "Unauthorized" })]
        ]
      end

      # Mock JSON com dado aleatório
      data = {
        id: rand(1000),
        name: ["Alice", "Bob", "Carol", "Dave"].sample,
        timestamp: Time.now.utc.iso8601
      }

      [
        200, 
        { "Content-Type" => "application/json" },
        [JSON.generate(data)]
      ]
    else
      [404, { "Content-Type" => "text/plain" }, ["Not Found"]]
    end
  end
end

use Rack::ContentLength
use Rack::CommonLogger

run ApiApp.new
