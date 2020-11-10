<%@ page language="java" contentType="text/html;  charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="pragma" content="no-cache"> 
<meta http-equiv="cache-control" content="no-cache"> 
<meta http-equiv="expires" content="0">
<script type="text/javascript" src="/LCS/js/jquery-2.2.4.js"></script>
<script type="text/javascript" src="/LCS/js/layer/layer.js"></script>
<script type="text/javascript" src="/LCS/js/jqjin/jqjin.js"></script>
<link  type="text/css"  rel="stylesheet" href="/LCS/css/index.css?version=1"/>
<title>Login Page</title>
</head>

<script>
$(document).ready(function(){
	//css. 由浏览器解析，不涉及服务器端的问题。所以可以跨域。
	//如果想在本台服务器上得到跨域文件，需要目标服务器的配合。
	//设置COR： Access-Control-Allow-Origin。
	//利用json实现访问。
	if("${username}"!=null&&"${username}".trim()!="")
	{
	    $(this).val('${username}');
		$(this).css('color','black');	
	}

	$("input[id='username']").click(function(){
		if($(this).val()=='username'){$(this).val('');}
		$(this).css('color','black');	
	});
	$("input[id='username']").focusout(function(){
	    if($(this).val()==''){$(this).val('username');
	    $(this).css('color','#c0c0c0');
	    }
	});
	
	$("input[id='password']").click(function(){
		if($(this).val()=='password'){$(this).val('');$(this).attr('type','password');}
		$(this).css('color','black');	
		
	});
	$("input[id='password']").focusout(function(){
	    if($(this).val()==''){$(this).val('password');$(this).attr('type','text');
	    $(this).css('color','#c0c0c0');	
	    }
	});
	
	
	$("button[id='login']").click(function(){
		//Verify the data.
		var username=$("input[id='username']").val();
		var password=$("input[id='password']").val();
		if(username==null||username.trim()=="")
		{
			$$.tips(null,$("input[id='username']"),{timeout:7000,content:"Username cannot be empty"});
		}
		else if(password==null||password.trim()=="")
		{
			$$.tips(null,$("input[id='password']"),{timeout:7000,content:"Password cannot be empty"});
		}
		else
		{
		    $("form").submit();
		    
		}
		
	});
	
	
	//This is for Sign up Response
	$("button[id='signup']").click(function(){
		//once click sign up, let's jump to the sign up page.
		$(location).attr('href', "signup.jsp")
		
	});
			
});






</script>
<body>

<!-- Define Window for showing messages 
<div id="window-message">
<div class="title" style="background-color:#5FB878">
Message
</div>
<div class="content">
</div>
</div>
  The message window will jump out under some conditions -->


<p id="webname">
L C S
</p>
<form id="loginform" method="post">
<table id="loginform">
<tbody>
<tr>
<td><input type="text" id="username" name="username" value="username"></td>
</tr>
<tr>
<td><input type="text" id="password" name="password" value="password"></td>
</tr>
<tr>
<td><button id="login" formaction="index.html">LOGIN</button></td>
</tr>
<c:if test='${message!=null&&message!=""}'>
<tr><td id='message'><button id='message' style=' width:101.2%;height:31px;background-color:#C9D0D1;opacity:0.6;'>${message}</button></td></tr>;
<c:set var="message" value="" scope="session"></c:set>
</c:if>
<tr>
<td><button  id="signup" formaction="javascript:void(0)">SIGN UP</button></td>
</tr>

</tbody>
</table>
</form>
</body>
</html>