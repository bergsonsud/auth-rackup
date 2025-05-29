require "rack"
require "./functions/api_protected"
require "securerandom"
require "jwt"

class ApiApp
  # Secret key for signing JWT tokens
  SECRET_KEY = "123456" # In production, use an environment variable
  
  def call(env)
    request = Rack::Request.new(env)

    if request.path == "/auth"
      # Generate a JWT token - in a real app, you would validate credentials first
      payload = {
        user_id: rand(1000),  # In a real app, this would be the actual user ID
        exp: Time.now.to_i + 3600  # Token expires in 1 hour
      }
      
      # Create the JWT token
      token = JWT.encode(payload, SECRET_KEY, 'HS256')
      
      return [
        200,
        { "Content-Type" => "application/json" },
        [JSON.generate({ token_type: "Bearer", access_token: token, expires_in: 3600 })]
      ]
    elsif request.path == "/api/protected"
      auth_header = request.env["HTTP_AUTHORIZATION"]
      
      # Check if Authorization header exists and starts with 'Bearer '
      if auth_header.nil? || !auth_header.start_with?("Bearer ")
        return [
          401, 
          { "Content-Type" => "application/json" },
          [JSON.generate({ error: "Unauthorized - Invalid token format" })]
        ]
      end
      
      # Extract the token
      token = auth_header.split(" ").last
      
      # Validate the JWT token
      begin
        # Decode and verify the token
        decoded_token = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })
        # Token is valid if we get here
      rescue JWT::ExpiredSignature
        return [
          401, 
          { "Content-Type" => "application/json" },
          [JSON.generate({ error: "Unauthorized - Token has expired" })]
        ]
      rescue JWT::DecodeError
        return [
          401, 
          { "Content-Type" => "application/json" },
          [JSON.generate({ error: "Unauthorized - Invalid token" })]
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
    elsif request.path == "/api/products"
      # Public endpoint that doesn't require authentication
      products = [
        { id: 1, name: "Smartphone", price: 999.99, category: "Electronics" },
        { id: 2, name: "Laptop", price: 1299.99, category: "Electronics" },
        { id: 3, name: "Headphones", price: 199.99, category: "Audio" },
        { id: 4, name: "Coffee Maker", price: 89.99, category: "Kitchen" },
        { id: 5, name: "Running Shoes", price: 129.99, category: "Sports" }
      ]
      
      [
        200,
        { "Content-Type" => "application/json" },
        [JSON.generate({ products: products })]
      ]
    else
      [404, { "Content-Type" => "text/plain" }, ["Not Found"]]
    end
  end
end

use Rack::ContentLength
use Rack::CommonLogger

run ApiApp.new
