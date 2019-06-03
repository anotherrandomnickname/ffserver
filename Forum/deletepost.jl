include("../PostgreSQLConn.jl")
include("./utils/checkaccess.jl")

function deletepost(fay::Main.Fairy.Dust)
    path = split(fay.request.target, "/")
    unique = path[length(path)]
    firebase_uid = path[length(path) - 1]
    postpk = fay.body["postpk"]
    topicpk = fay.body["topicpk"]
    forumpk = fay.body["forumpk"]
    if unique != UNIQUE_IDENTIFY
        fay.response.status = 403
    elseif check_access(firebase_uid, postpk)
        inject_me_master = 
        """
            DO
            '
            BEGIN
            IF EXISTS(SELECT pk FROM posts WHERE pk = $postpk) THEN
                DELETE FROM posts
                WHERE pk = $postpk;
            UPDATE users
                SET total_posts = total_posts - 1
                WHERE firebase_uid = ''$firebase_uid'';
            UPDATE topics
                SET last_uid = subquery.rel_user,
                    total_posts = total_posts - 1,
                    last_postdate = subquery.post_date
                FROM (SELECT rel_user, post_date FROM posts
                    WHERE rel_topic = $topicpk
                    AND post_date = (select max(post_date) from posts WHERE rel_topic = $topicpk)) AS subquery
                WHERE topics.pk = $topicpk;
            UPDATE forums
                SET rel_tid = subquery.rel_topic
                FROM(
                    SELECT MAX(post_date),
                        subquery_junior.rel_topic
                    FROM(
                    SELECT * FROM posts
                    INNER JOIN topics AS top ON(top.pk = posts.rel_topic)
                    WHERE top.rel_fid = $forumpk
                    GROUP BY posts.pk, top.pk
                    ) AS subquery_junior
                    GROUP BY subquery_junior.rel_topic
                ) AS subquery
                WHERE forums.pk = $forumpk;
            COMMIT;
            END IF;
            END
            '
        """
        deleted_post = fetch!(NamedTuple, execute(
            conn,
            inject_me_master
        ))
        fay.response.status = 200
    else
        fay.response.status = 403
    end

    return fay
end