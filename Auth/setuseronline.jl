include("../PostgreSQLConn.jl")

#= println("TARGET 1: ", path[length(path)])
println("TARGET 2: ", path[length(path) - 1]) =#

function setuseronline(fay::Main.Fairy.Dust)
	user = fay.body
	uid = user["uid"]
	inject_me_master = """
	UPDATE users
	SET is_online = true
	WHERE firebase_uid = '$uid'
	"""

	set_user_online = fetch!(NamedTuple, execute(
        conn,
        inject_me_master
    ))
	return fay
end
