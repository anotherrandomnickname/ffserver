include("../PostgreSQLConn.jl")

function createtheme(fay::Main.Fairy.Dust)
    path = split(fay.request.target, "/")
    unique = path[length(path)]
    if unique != UNIQUE_IDENTIFY
        fay.response.status = 403
    else
        uid = path[length(path) - 1]
        body = fay.body["body"]
        name = fay.body["name"]
        description = fay.body["description"]
        userpk = fay.body["userpk"]
        fid = fay.body["fid"]

        println("BODY:", fay.body)

        inject_me_master = 
        """
            DO
            '
            BEGIN
            UPDATE users
                SET total_posts = total_posts + 1
                WHERE firebase_uid = ''$uid'';
            INSERT INTO topics(
                rel_fid, name, description, last_uid, topicstarter_uid, topic_body, last_postdate
            )
            VALUES (
            $fid,
            ''$name'',
            ''$description'',
            $userpk,
            $userpk,
            ''$body'',
            NOW() at time zone(''utc'')
            );
            UPDATE forums
                SET rel_tid = currval(pg_get_serial_sequence(''topics'', ''pk''))
                WHERE pk = $fid;
            END
            '
	    """

        new_theme = fetch!(NamedTuple, execute(
            conn,
            inject_me_master
        ))
        fay.response.status = 200
    end
    return fay
end