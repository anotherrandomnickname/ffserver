using JSON
using HttpCommon
using HTTP
import HTTP.IOExtras.bytes


struct PathHandler{T}
    path::String
    method::String
    handler::T
    origin::String
end

mutable struct Fairy
    body
    response::HTTP.Response
    request::HTTP.Request
end

handlers =  PathHandler[]
PATH_SALT = "FVa3vxsIjScs"

function parse(fay::Fairy)
    if !isempty(fay.request.body)
        fay.body = JSON.parse(String(fay.request.body))
    end
    return fay
end

function sendJSON(fay::Fairy)
    fay.response.body = bytes(JSON.json(fay.body))
    return fay
end

function add_headers(fay::Fairy)
    push!(fay.response.headers, Pair("Access-Control-Allow-Methods", "POST, GET"))
    push!(fay.response.headers, Pair("Access-Control-Allow-Headers", " Origin, Content-Type, X-Auth-Token"))
    push!(fay.response.headers, Pair("Content-Type", "application/json"))
    return fay
end

function set_status(fay::Fairy)
    fay.response.status = 200
    return fay
end

function use!(func::Function)
    push!(middleware, func)
end

function stack(layers)
    println("STACK")
    return function(req::HTTP.Request)
        fay = Fairy("", HTTP.Response(), req)
        res = HTTP.Response()
        for l in layers
            (fay) = l(fay)
        end
        return fay.response
    end
end

function register!(path::String, method::String, handler::Function, origin::String="*", isSalted::Bool=false)
    if isSalted
        push!(handlers, PathHandler(path *PATH_SALT, method, handler, origin))
    else
        push!(handlers, PathHandler(path, method, handler, origin))
    end
end

function access_control(fay::Fairy)
    HTTP.Messages.setheader(fay.response, "Access-Control-Allow-Origin" => "*")
    return fay
end

function serve!(address::String, port::Int)
    router = HTTP.Router()
    for handler in handlers
        HTTP.register!(router, "OPTIONS", handler.path, stack([middleware..., access_control]))
        HTTP.register!(router, handler.method, handler.path, stack([middleware..., handler.handler, sendJSON]))
    end
    s = HTTP.Servers.Server(router) 
    HTTP.serve(s, address, port)
end


function testHandler(fay::Fairy)
    fay.body = Dict("test"=> "test-parameter423423!")
    return fay
end

middleware = [add_headers, set_status, parse]

register!("/test", "GET", testHandler)

serve!("127.0.0.1", 3800)


#= HTTP.register!(router, "OPTIONS", "/logout", stack([middleware..., enableCors]))
HTTP.register!(router, "POST", "/logout", stack([middleware..., Auth.logout]))

register!("this is path", handler, "*", false)
register!("this is SALTED PATH", handler, true)
 =#



 	println("START FORUM FETCING")
    amphetamine_injection = """
	SELECT forums.pk AS fpk, sec.pk AS section, forums.order_by AS order, 
	sec.name AS section_name, forums.name AS forum_name , forums.description AS forum_description,
	top.name AS last_topic_name, lu.name AS last_user_name,
	lu.role_claims AS last_user_role,
	top.last_postdate AS last_post_date,
	top.pk AS topic_pk,
	lu.pk AS user_pk
	FROM forums
	LEFT JOIN section AS sec ON(forums.section_pk = sec.pk)
	LEFT JOIN topics AS top ON (forums.rel_tid = top.pk)
	LEFT JOIN users AS lu ON (top.last_uid = lu.pk)
	GROUP BY sec.pk, forums.pk, top.pk, lu.pk
	 """

	data = fetch!(NamedTuple, execute(
    	conn,
    	amphetamine_injection
	))
	