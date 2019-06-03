
include("./Models/Fairy.jl")
include("./Forum/Forum.jl")
include("./Auth/Auth.jl")
include("./Profile/Profile.jl")
#= 
function splitpath(fay::Main.Fairy.Dust)
    path = split(fay.request.target, "/")
    println("TARGET 1: ", path[length(path)])
    println("TARGET 2: ", path[length(path) - 1])
    println("TARGET 3: ", path[length(path) - 2])
    fay.body = Dict("status"=> "SUCCESS")
    return fay
end =#

path_salt = Fairy.PATH_SALT

Fairy.register!("/forum", "GET", Forum.viewforum)
Fairy.register!("/subforum/*", "GET", Forum.viewsubforum)
Fairy.register!("/theme/*/*", "GET", Forum.viewtheme)
Fairy.register!("/createpost/$path_salt/*/*", "PUT", Forum.createpost)
Fairy.register!("/updatepost/$path_salt/*/*", "POST", Forum.updatepost)
Fairy.register!("/deletepost/$path_salt/*/*", "POST", Forum.deletepost)
Fairy.register!("/createtheme/$path_salt/*/*", "PUT", Forum.createtheme)
Fairy.register!("/deletetheme/$path_salt/*/*", "POST", Forum.deletetheme)
Fairy.register!("/updatetheme/$path_salt/*/*", "POST", Forum.updatetheme)
Fairy.register!("/sessionlogin/$path_salt/*/*", "GET", Auth.sessionlogin)
Fairy.register!("/register/$path_salt/*/*", "PUT", Auth.register)
Fairy.register!("/set_user_online/$path_salt", "POST", Auth.setuseronline)
Fairy.register!("/set_user_offline/$path_salt", "POST", Auth.setuseroffline)
Fairy.register!("/setonlineinitial/$path_salt", "POST", Auth.setonlineinitial)
Fairy.register!("/profile/*", "GET", Profile.viewprofile)
Fairy.register!("/own_user_profile/$path_salt/", "GET", Profile.view_own_user_profile)

Fairy.serve!("127.0.0.1", 8010)

