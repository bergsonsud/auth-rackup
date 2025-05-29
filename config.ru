require "rack"
require "./functions/api_protected"

run Proc.new { |env|
  request = Rack::Request.new(env)

  if request.path == "/api/protected"
    result = handler(
      event: {
        "headers" => { "authorization" => request.env["HTTP_AUTHORIZATION"] }
      },
      context: {}
    )

    [
      result[:statusCode],
      result.fetch(:headers, {}),
      [result[:body]]
    ]
  else
    [404, { "Content-Type" => "text/plain" }, ["Not Found"]]
  end
}
