include("../PostgreSQLConn.jl")
include("./utils/checkaccess.jl")

function updatepost(fay::Main.Fairy.Dust)
    path = split(fay.request.target, "/")
    unique = path[length(path)]
    firebase_uid = path[length(path) - 1]
    postpk = fay.body["postpk"]
    if unique != UNIQUE_IDENTIFY
        fay.response.status = 403
    elseif check_access(firebase_uid, postpk)
        println("POSTPK: ", fay.body["postpk"][1])
        println("POST: ", fay.body["post"])
        post = fay.body["post"]
        inject_me_master = 
        """
            UPDATE posts
            SET post_body = '$post'
            WHERE pk = $postpk
        """
        update_post = fetch!(NamedTuple, execute(
            conn,
            inject_me_master
        ))
        fay.response.status = 200
    else 
        fay.response.status = 403
    end
    return fay
end