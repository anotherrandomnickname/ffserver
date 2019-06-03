using HTTP

mutable struct Dust
    body
    response::HTTP.Response
    request::HTTP.Request
end