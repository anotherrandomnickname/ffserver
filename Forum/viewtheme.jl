include("../PostgreSQLConn.jl")

function viewtheme(fay::Main.Fairy.Dust)
    path = split(fay.request.target, "/")
    id = path[length(path) - 1]

    mescaline_injection_2 = """
        WITH topic_view AS(
        UPDATE topics
        SET total_views = total_views + 1
        WHERE topics.pk = $id
        RETURNING *
        )
        SELECT topic_view.pk AS pk, topic_view.description, topic_view.created_on, topic_view.topic_body, topic_view.total_posts AS topic_total_posts,
            topic_view.topicstarter_uid AS ts_uid, topic_view.name AS topic_name, topic_view.total_views,
            ts.name AS ts_name, ts.role_claims as ts_role, ts.total_posts AS ts_total_posts, ts.current_title AS ts_current_title,
            ts.signature AS ts_signature, ts.is_online AS ts_is_online
            FROM topic_view
        INNER JOIN users AS ts ON(topicstarter_uid = ts.pk)
    """

    topic_check = fetch!(NamedTuple, execute(
        conn,
        mescaline_injection_2
    ))


    if isempty(topic_check[:pk])
        fay.response.status = 404
    else
        posts_per_page = 15
        page = path[length(path)]
        offset = (tryparse(Float64, page) - 1) * posts_per_page
        mescaline_injection = """
            SELECT posts.pk AS post_pk, posts.post_body, posts.post_date, posts.likes AS post_likes,
                posts.rel_user, us.name AS user_name, us.role_claims AS user_role, us.pk AS user_pk, 
                us.total_posts AS user_posts, us.current_title AS user_current_title,
                us.signature AS user_signature, us.is_online AS user_is_online
            FROM posts
            INNER JOIN users AS us ON(posts.rel_user = us.pk)
            WHERE rel_topic = $id
            ORDER BY posts.post_date
            LIMIT $posts_per_page OFFSET $offset
        """

        posts = fetch!(NamedTuple, execute(
            conn,
            mescaline_injection
        ))

        fay.body = Dict(
            "pk"               => topic_check[:pk][1],
            "topic_body"       => topic_check[:topic_body][1],
            "topic_description"=> topic_check[:description][1],
            "topic_name"       => topic_check[:topic_name][1],
            "topic_total_posts"=> topic_check[:topic_total_posts][1],
            "created_on"       => topic_check[:created_on][1],
            "ts_pk"            => topic_check[:ts_uid][1],
            "ts_name"          => topic_check[:ts_name][1],
            "ts_role"          => topic_check[:ts_role][1],
            "ts_total_posts"   => topic_check[:ts_total_posts][1],
            "ts_current_title" => topic_check[:ts_current_title][1],
            "ts_signature"     => topic_check[:ts_signature][1],
            "ts_is_online"     => topic_check[:ts_is_online][1],
            "data"             => posts
        )
        
        fay.response.status = 200
    end

    return fay
end