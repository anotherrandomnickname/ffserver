using JSON
using HTTP
import HTTP.IOExtras.bytes
include("./PostgreSQLConn.jl")



function logout(req::HTTP.Request, res::HTTP.Response)
	reqBody = JSON.parse(String(req.body))
	token = reqBody["token"]
	
	r = """
        UPDATE $(tables.users)
        SET token = ''
        WHERE token = '$token'
        """

	data = fetch!(NamedTuple, execute(
		conn,
		r
	))

	res.body = bytes(JSON.json(Dict("status"=> 200)))
	return (req, res)
end