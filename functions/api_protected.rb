require "json"

def handler(event:, context:)
  auth_header = event["headers"]["authorization"]
  token = auth_header&.split(" ")&.last

  if token != "123456"
    return {
      statusCode: 401,
      body: JSON.generate({ error: "Unauthorized" })
    }
  end

  # Mock JSON com dado aleatório
  data = {
    id: rand(1000),
    name: ["Alice", "Bob", "Carol", "Dave"].sample,
    timestamp: Time.now.utc.iso8601
  }

  {
    statusCode: 200,
    headers: { "Content-Type" => "application/json" },
    body: JSON.generate(data)
  }
end
