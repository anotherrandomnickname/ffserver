include("../PostgreSQLConn.jl")

function view_own_user_profile(fay::Main.Fairy.Dust)
    path = split(fay.request.target, "/")
    uid = fay.body["uid"]
    inject_me_master = 
        """
            SELECT users.name, users.gender, users.role_claims, users.total_posts, 
            users.titles, users.current_title, users.signature, users.is_online,
            users.photourl, users.pk
            FROM users
            WHERE firebase_uid = '$uid'
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