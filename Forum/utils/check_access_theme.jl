using JSON
using HTTP
import HTTP.IOExtras.bytes
include("../../PostgreSQLConn.jl")


function check_access_theme(firebase_uid, topicpk)
    inject_me_master = 
    """
        WITH theme_check AS(
            SELECT us.firebase_uid as firebase_uid FROM topics
            INNER JOIN users AS us ON(topics.topicstarter_uid = us.pk)
            WHERE topics.pk = $topicpk
            GROUP BY topics.pk, us.pk
        ),
        user_check AS(
            SELECT role_claims as demand_accesslvl
            FROM users
            WHERE firebase_uid = '$firebase_uid'
        )
        SELECT * from theme_check, user_check
        GROUP BY theme_check.firebase_uid, user_check.demand_accesslvl
    """

    query = fetch!(NamedTuple, execute(
        conn,
        inject_me_master
    ))

    if query[:firebase_uid][1] == firebase_uid
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