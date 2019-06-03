using JSON
using HTTP
import HTTP.IOExtras.bytes
include("./PostgreSQLConn.jl")



function login(req::HTTP.Request, res::HTTP.Response)
    #= println(JSON.parse(String(req.body))) =#
    println("Hello darkness smile friend")
    println(req.body)
    reqBody = JSON.parse(String(req.body))
    reqLog = reqBody["login"]
    reqPass = reqBody["password"]
    token = reqBody["token"]
    println(reqBody)
    #= request = JSON.parse(String(req.body)) =#
    r = """
        SELECT *
        FROM $(tables.users)
        WHERE name = '$reqLog'
        AND pass = crypt('$reqPass', pass) """

    data = fetch!(NamedTuple, execute(
        conn,
        r
    ))

    if isempty(data[:id])
        res.body = bytes(JSON.json(Dict("error"=> 20)))
    else
        setToken = """
        UPDATE $(tables.users)
        SET token = '$token'
        WHERE name = '$reqLog'
        AND pass = crypt('$reqPass', pass)
        """

        fetch!(NamedTuple, execute(
            conn,
            setToken
        ))

        data2 = fetch!(NamedTuple, execute(
            conn,
            r
        ))

        res.body = bytes(JSON.json(Dict("name"=> data2[:name][1], "email"=> data2[:email][1], "token"=> data2[:token][1])))
    end

    return (req, res)
end