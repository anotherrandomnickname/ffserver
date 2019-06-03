using Mux
using JSON
using HttpCommon
using HTTP
import HTTP.IOExtras.bytes

include("./Auth/Auth.jl")
include("./Forum/forum.jl")
include("./Forum/topics.jl")
include("./Forum/theme.jl")
include("./Forum/createpost.jl")
include("./Forum/deletepost.jl")

# Define a bunch of middleware layers that take the request and response and return
# modified copies
function add_headers(req::HTTP.Request, res::HTTP.Response)
    push!(res.headers, Pair("Access-Control-Allow-Methods", "POST, GET"))
    push!(res.headers, Pair("Access-Control-Allow-Headers", " Origin, Content-Type, X-Auth-Token"))
    push!(res.headers, Pair("Content-Type", "application/json"))
    return (req, res)
end

function set_status(req::HTTP.Request, res::HTTP.Response)
    res.status = 200
    return (req, res)
end

function parse(req::HTTP.Request, res::HTTP.Response)
    req.body = JSON.Parse(String(req.body))
    return (req, res)
end

middleware = [add_headers, set_status, parse]

# A endpoint is just like any other middleware but it should probably do things like
# populate the response body

# A function to combine layers -- presumably something like this would be added 
# to HTTP or would be left to packages like an updated Mux
function stack(layers)
    println("STACK")
    res = HTTP.Response()
    HTTP.Messages.setheader(res, "Access-Control-Allow-Origin"=> "*")
    return function(req::HTTP.Request)
        for l in layers
            #= println(typeof(l)) =#
            (req, res) = l(req, res)
        end
        return res
    end
end

function enableCors(req::HTTP.Request, res::HTTP.Response)
    HTTP.Messages.setheader(res, "Access-Control-Allow-Origin"=> "*")
    return (req, res)
end

router = HTTP.Router()
res = HTTP.Response()

HTTP.register!(router, "OPTIONS", "//*", stack([middleware..., enableCors]))

HTTP.register!(router, "OPTIONS", "/login", stack([middleware..., enableCors]))
HTTP.register!(router, "POST", "/login", stack([middleware..., Auth.login]))

HTTP.register!(router, "OPTIONS", "/logout", stack([middleware..., enableCors]))
HTTP.register!(router, "POST", "/logout", stack([middleware..., Auth.logout]))

HTTP.register!(router, "OPTIONS", "/register$PATH_SALT", stack([middleware..., enableCors]))
HTTP.register!(router, "POST", "/register$PATH_SALT", stack([middleware..., Auth.register]))

HTTP.register!(router, "OPTIONS", "/sessionlogin$PATH_SALT", stack([middleware..., enableCors]))
HTTP.register!(router, "POST", "/sessionlogin$PATH_SALT", stack([middleware..., Auth.sessionlogin]))

HTTP.register!(router, "OPTIONS", "/forum", stack([middleware..., enableCors]))
HTTP.register!(router, "GET", "/forum", stack([middleware..., forum]))

HTTP.register!(router, "OPTIONS", "/subforum", stack([middleware..., enableCors]))
HTTP.register!(router, "POST", "/subforum", stack([middleware..., topics]))

HTTP.register!(router, "OPTIONS", "/theme", stack([middleware..., enableCors]))
HTTP.register!(router, "POST", "/theme", stack([middleware..., theme]))

HTTP.register!(router, "OPTIONS", "/createpost$PATH_SALT", stack([middleware..., enableCors]))
HTTP.register!(router, "POST", "/createpost$PATH_SALT", stack([middleware..., createpost]))

HTTP.register!(router, "OPTIONS", "/deletepost$PATH_SALT", stack([middleware..., enableCors]))
HTTP.register!(router, "POST", "/deletepost$PATH_SALT", stack([middleware..., deletepost]))

HTTP.register!(router, "OPTIONS", "/updatepost$PATH_SALT", stack([middleware..., enableCors]))
HTTP.register!(router, "POST", "/updatepost$PATH_SALT", stack([middleware..., updatepost]))
#=
HTTP.register!(router, "GET", "/logout", stack([our_middleware..., endpoint1]))
HTTP.register!(router, "GET", "/register", stack([our_middleware..., endpoint1]))
HTTP.register!(router, "GET", "/login", stack([our_middleware..., endpoint1]))

=#

s = HTTP.Servers.Server(router) 
HTTP.serve(s, "127.0.0.1", 8010)