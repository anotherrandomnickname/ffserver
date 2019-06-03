module Fairy

    using JSON
    using HttpCommon
    using HTTP
    import HTTP.IOExtras.bytes
    include("./ResponseStruct.jl")

    struct PathHandler{T}
        path::String
        method::String
        handler::T
        origin::String
    end

    handlers =  PathHandler[]
    PATH_SALT = "FVa3vxsIjScs"

    function parse(fay::Dust)
        if !isempty(fay.request.body)
            fay.body = JSON.parse(String(fay.request.body))
        end
        return fay
    end

    function sendJSON(fay::Dust)
        fay.response.body = bytes(JSON.json(fay.body))
        return fay
    end

    function add_headers(fay::Dust)
        push!(fay.response.headers, Pair("Access-Control-Allow-Methods", "POST, GET, PUT, UPDATE"))
        push!(fay.response.headers, Pair("Access-Control-Allow-Headers", " Origin, Content-Type, X-Auth-Token"))
        push!(fay.response.headers, Pair("Content-Type", "application/json"))
        return fay
    end

    function set_status(fay::Dust)
        fay.response.status = 200
        return fay
    end

    function use!(func::Function)
        push!(middleware, func)
    end

    function stack(layers)
        return function(req::HTTP.Request)
            res = HTTP.Response()
            HTTP.Messages.setheader(res, "Access-Control-Allow-Origin"=> "*")
            fay = Dust("", res, req)
            for l in layers
                (fay) = l(fay)
            end
            return fay.response
        end
    end

    function access_control(fay::Dust)
        HTTP.Messages.setheader(fay.response, "Access-Control-Allow-Origin" => "*")
        return fay
    end


    function register!(path::String, method::String, handler, origin::String="*", isSalted::Bool=false)
        if isSalted
            push!(handlers, PathHandler(path *PATH_SALT, method, handler, origin))
        else
            push!(handlers, PathHandler(path, method, handler, origin))
        end
    end

    function serve!(address::String, port::Int)
        router = HTTP.Router()
        for handler in handlers
            HTTP.register!(router, "OPTIONS", handler.path, stack([middleware..., access_control]))
            println("REGISTERED HANDLER: ", handler.handler)
            HTTP.register!(router, handler.method, handler.path, stack([middleware..., handler.handler, sendJSON]))
        end
        s = HTTP.Servers.Server(router) 
        HTTP.serve(s, address, port)
    end

    middleware = [parse, add_headers, set_status]

end