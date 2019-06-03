include("../PostgreSQLConn.jl")

function createpost(fay::Main.Fairy.Dust)
    path = split(fay.request.target, "/")
    unique = path[length(path)]
    if unique != UNIQUE_IDENTIFY
        fay.response.status = 403
    else
        uid = path[length(path) - 1]
        tid = fay.body["tid"]
        post = fay.body["post"]
        fid = fay.body["fid"]

        inject_me_master = 
        """
        WITH new_post AS(
            INSERT INTO posts(rel_topic, rel_user, post_body)
            VALUES(
                $tid, 
                (SELECT pk FROM users WHERE firebase_uid = '$uid') , 
                '$post'
            )
            RETURNING *
        ),
        update_topic AS(
            UPDATE topics
            SET last_postdate = NOW() at time zone('utc'), last_uid = (SELECT pk FROM users WHERE firebase_uid = '$uid'), total_posts = total_posts + 1
            WHERE topics.pk = $tid
            RETURNING *
        ),
        update_user AS(
            UPDATE users
            SET total_posts = total_posts + 1
            WHERE firebase_uid = '$uid'
        ),
        update_forum AS(
            UPDATE forums
            SET rel_tid = $tid
            WHERE pk = $fid
            )
        SELECT * FROM new_post
        """

        new_post = fetch!(NamedTuple, execute(
            conn,
            inject_me_master
        ))

        if isempty(new_post[:rel_user])
            fay.response.status = 400
        else
            fay.response.status = 201
        end
    end
    return fay
end