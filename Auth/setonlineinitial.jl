include("../PostgreSQLConn.jl")

#= println("TARGET 1: ", path[length(path)])
println("TARGET 2: ", path[length(path) - 1]) =#

function setonlineinitial(fay::Main.Fairy.Dust)
	users = fay.body
	println("USERS:", users)
	transaction = ""
	for user in users
		println(user[1])
		uid = user[1]
		if haskey(user[2], "connections")
			println("USER ", uid, "CONNECTED!")
			transaction = string(transaction, "UPDATE users SET is_online = true WHERE firebase_uid = ''$uid''; ")
		end
	end

	println("TRANSACTION:", transaction)

	inject_me_master = """
	DO 
	'
		BEGIN
		UPDATE users
		SET is_online = false;
		$transaction
		END
	'
	"""

	set_users_online = fetch!(NamedTuple, execute(
        conn,
        inject_me_master
    ))
	println("INJECTION: ", inject_me_master)
	return fay
end