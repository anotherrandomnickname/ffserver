include("../PostgreSQLConn.jl")

function viewforum(fay::Main.Fairy.Dust)
    println("START FORUM FETCING")
    amphetamine_injection = """
	SELECT forums.pk AS fpk, sec.pk AS section, forums.order_by AS order, 
	sec.name AS section_name, forums.name AS forum_name , forums.description AS forum_description,
	top.name AS last_topic_name, lu.name AS last_user_name,
	lu.role_claims AS last_user_role,
	top.last_postdate AS last_post_date,
	top.pk AS topic_pk,
	lu.pk AS user_pk
	FROM forums
	LEFT JOIN section AS sec ON(forums.section_pk = sec.pk)
	LEFT JOIN topics AS top ON (forums.rel_tid = top.pk)
	LEFT JOIN users AS lu ON (top.last_uid = lu.pk)
	GROUP BY sec.pk, forums.pk, top.pk, lu.pk
	 """

	forum = fetch!(NamedTuple, execute(
    	conn,
    	amphetamine_injection
	))
	fay.body = forum
    return fay
end