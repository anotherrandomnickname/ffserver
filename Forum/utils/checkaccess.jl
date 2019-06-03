using JSON
using HTTP
import HTTP.IOExtras.bytes
include("../../PostgreSQLConn.jl")


function check_access(firebase_uid, postpk)
    inject_me_master = 
    """
        WITH post_check AS(
            SELECT us.firebase_uid as post_firebase_uid FROM posts
            INNER JOIN users AS us ON(posts.rel_user = us.pk)
            WHERE posts.pk = $postpk
            GROUP BY posts.pk, us.pk
        ),
        user_check AS(
            SELECT role_claims as demand_accesslvl
            FROM users
            WHERE firebase_uid = '$firebase_uid'
        )
        SELECT * from post_check, user_check
        GROUP BY post_check.post_firebase_uid, user_check.demand_accesslvl
    """

    query = fetch!(NamedTuple, execute(
        conn,
        inject_me_master
    ))

    if query[:post_firebase_uid][1] == firebase_uid
        ## OK
        return true
    elseif query[:demand_accesslvl][1] >= 7
        ## OK
        return true
    else 
        ## NOT OK
        return false
    end
end