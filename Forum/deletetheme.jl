include("../PostgreSQLConn.jl")
include("./utils/checkaccess.jl")
include("./utils/check_access_theme.jl")

function deletetheme(fay::Main.Fairy.Dust)
    path = split(fay.request.target, "/")
    unique = path[length(path)]
    firebase_uid = path[length(path) - 1]
    print("FIREBASEUID", firebase_uid)
    topicpk = fay.body["tid"]
    forumpk = fay.body["fid"]
    if unique != UNIQUE_IDENTIFY
        fay.response.status = 403
    elseif check_access_theme(firebase_uid, topicpk)
        inject_me_master = 
        """
        DO
        '
        BEGIN
        IF EXISTS(SELECT pk FROM topics WHERE pk = $topicpk) THEN
        UPDATE forums
        SET rel_tid = null
        WHERE pk = $forumpk;
        DELETE FROM posts
            WHERE rel_topic = $topicpk;
        DELETE FROM topics
            WHERE pk = $topicpk;
        UPDATE users
            SET total_posts = total_posts - 1
            WHERE firebase_uid = ''$firebase_uid'';
        UPDATE forums
        SET rel_tid = subquery.pk
        FROM (
            SELECT pk
            FROM topics
            WHERE last_postdate = (
                SELECT MAX(last_postdate)
                FROM topics
                WHERE rel_fid = $forumpk
            )
        ) as subquery
        WHERE forums.pk = $forumpk;
        COMMIT;
        END IF;
        END
        '
        """
        delete_theme = fetch!(NamedTuple, execute(
            conn,
            inject_me_master
        ))
        fay.response.status = 200
    else
        fay.response.status = 403
    end

    return fay
end