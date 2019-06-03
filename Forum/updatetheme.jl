include("../PostgreSQLConn.jl")
include("./utils/check_access_theme.jl")

function updatetheme(fay::Main.Fairy.Dust)
    path = split(fay.request.target, "/")
    unique = path[length(path)]
    firebase_uid = path[length(path) - 1]
    pk = fay.body["pk"]
    if unique != UNIQUE_IDENTIFY
        fay.response.status = 403
    elseif check_access_theme(firebase_uid, pk)
        description = fay.body["description"]
        body = fay.body["body"]
        name = fay.body["name"]
        inject_me_master = 
        """
            UPDATE topics
            SET name = '$name',
                description = '$description',
                topic_body = '$body'
            WHERE pk = $pk
        """
        update_topic = fetch!(NamedTuple, execute(
            conn,
            inject_me_master
        ))
        fay.response.status = 200
    else 
        fay.response.status = 403
    end
    return fay
end