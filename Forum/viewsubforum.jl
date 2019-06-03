include("../PostgreSQLConn.jl")

function viewsubforum(fay::Main.Fairy.Dust)
    path = split(fay.request.target, "/")
    forum_id = path[length(path)]

    cocaine_injection_2 = """
    SELECT name, description, pic, pk
    FROM forums
    WHERE pk = $forum_id
    """

    forum_check = fetch!(NamedTuple, execute(
        conn,
        cocaine_injection_2
    ))


    if isempty(forum_check[:name])
        fay.response.status = 404
    else
        cocaine_injection = """
        SELECT topics.pk, topics.name, topics.last_postdate,
            topics.total_views AS total_views,
            topics.total_posts AS total_posts,
            lu.pk AS last_user_pk, lu.name AS last_user_name, 
            lu.role_claims AS last_user_role, topics.description, topics.is_fixed,
            ts.pk AS topicstarter_pk, ts.name AS topicstarter_name, ts.role_claims AS topicstarter_role
        FROM topics
        INNER JOIN users AS lu ON(topics.last_uid = lu.pk)
        INNER JOIN users AS ts ON(topics.topicstarter_uid = ts.pk)
        WHERE topics.rel_fid = $forum_id
        GROUP BY topics.pk, lu.pk, ts.pk
        ORDER BY topics.last_postdate desc

        """

        topics = fetch!(NamedTuple, execute(
            conn,
            cocaine_injection
        ))

        fay.body = Dict(
            "forum_name" => forum_check[:name][1],
            "forum_description" => forum_check[:description][1],
            "forum_pic" => forum_check[:pic][1],
            "forum_pk" => forum_check[:pk][1],
            "data" => topics
        )
        
        fay.response.status = 200
    end
    return fay
end