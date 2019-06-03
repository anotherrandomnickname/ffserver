include("../PostgreSQLConn.jl")

function viewprofile(fay::Main.Fairy.Dust)
    path = split(fay.request.target, "/")
    pk = path[length(path)]
    inject_me_master = 
        """
            SELECT users.name, users.gender, users.role_claims, users.total_posts, 
            users.titles, users.current_title, users.signature, users.is_online,
            users.photourl, users.pk
            FROM users
            WHERE pk = $pk
        """


    profile = fetch!(NamedTuple, execute(
        conn,
        inject_me_master
    ))
    if isempty(profile[:pk])
        fay.response.status = 404
    else
        fay.body = profile
        fay.response.status = 200
    end
    return fay
end