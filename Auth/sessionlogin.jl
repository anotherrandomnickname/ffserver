include("../PostgreSQLConn.jl")

#= println("TARGET 1: ", path[length(path)])
println("TARGET 2: ", path[length(path) - 1]) =#

function sessionlogin(fay::Main.Fairy.Dust)
	path = split(fay.request.target, "/")
	unique = path[length(path)]
	if unique == UNIQUE_IDENTIFY
		firebase_uid = path[length(path) - 1]
		heroin_injection = 
		"""
		WITH session_login AS
		(
			UPDATE users
			SET last_login = NOW() at time zone('utc')
			WHERE firebase_uid = '$firebase_uid'
			RETURNING name, pk, gender, last_login, created_on, role_claims
		)
		SELECT *
		FROM session_login
		"""

		user = fetch!(NamedTuple, execute(
			conn,
			heroin_injection
		))

		if isempty(user[:name])
			fay.response.status = 204
		else
			fay.body = Dict(
				"pk"         => user[:pk][1],
				"name"       => user[:name][1],
				"gender"     => user[:gender][1],
				"created_on" => user[:created_on][1],
				"last_login" => user[:last_login][1]
			)
			fay.response.status = 200
		end
	else
		fay.response.status = 401
	end

	return fay
end