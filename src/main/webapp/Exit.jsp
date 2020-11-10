<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page language="java" import="lcs.domain.User,lcs.dao.UserDao" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
<script>

</script>
<style>
img
{
float:left;
height:80px;

}
ul{
list-style-type:none;
margin-left:20px;
text-align:center;
color:blue;
}

#option
{
   margin-bottom:0px;
   background-color:white;
   height:30px;
   border-top:0.1px solid gray;
   border-bottom:0px;
   border-left:0px;
   text-aligh:center;
}
button
{
   height:25px;
   width:80px;
   font-size:15px;
   font-family:times new roman;
   pointer:hand;
}
#logout
{
 float:left;
 margin-left:20px;
}
#exit
{
float:right;
margin-right:20px;
}
</style>
</head>
<body>
<div>
<img id='idimg' src="resource/userdata/${user.username}/face.jpg" alt="${user.username}"/>
<ul><li><a>${username}</a></li><li>${user.email}</li></ul>

</div>	
<div id='option'>
<button id='change password'>change password</button>
<button id='logout'>LogOut</button>
</div>
</body>
</html>