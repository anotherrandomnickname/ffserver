
include("../PostgreSQLConn.jl")
function register(fay::Main.Fairy.Dust)
    path = split(fay.request.target, "/")
    unique = path[length(path)]
	firebase_uid = path[length(path) - 1]
	if unique == UNIQUE_IDENTIFY
		firebase_uid = path[length(path) - 1]
		name = fay.body["name"]
		role = fay.body["accessLevel"]
		heroin_injection = """
		WITH new_user AS(
		INSERT INTO users(firebase_uid, name, last_login, role_claims)
		VALUES(
		'$firebase_uid',
		'$name',
		NOW() at time zone('utc'),
		$role )
		RETURNING name, pk, gender, last_login, created_on, role_claims
		)
		SELECT name, pk, gender, last_login, created_on, role_claims
		FROM new_user
		"""

		new_user = fetch!(NamedTuple, execute(
			conn,
			heroin_injection
		))

		fay.body = Dict(
			"name"=> name
		)
		fay.response.status = 200
	else
		fay.response.status = 403 
	end
	return fay
end
