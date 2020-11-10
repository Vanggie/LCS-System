<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE>
<link  rel="stylesheet" type="text/css" href="css/addText.css?version=4"/>
<script type="text/javascript" src="js/jquery-2.2.4.js"></script>
<script type="text/javascript" src="js/jqjin/jqjin.js"></script>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Add a text</title>
<script>
$(document).ready(function(){
	$("#submit").click(function(){
		//Verify form
		var projectname=$("#projectname").val();
		var projecttext=$("#projecttext").val();
		if(projectname==null||$.trim(projectname)=="")
		{
			$$.tips("message",$("#projectname"),{content:"Project name cannot be empty",timeout:"3000",attachposition:"2"});
			if(projecttext==null||$.trim(projecttext)=="")
			{
				$$.tips("message",null,{content:"Input text cannot be empty",timeout:"3000",attachposition:"2"});
			}
		}
		else if(projecttext==null||$.trim(projecttext)=="")
		{
			$$.tips("message",null,{content:"Input text cannot be empty",timeout:"3000",attachposition:"2"});
		}
		else
	    {
		     ///do post form, use ajax;
		     $.ajax({
		         url:"addText",
		         contentType:"application/json;charset=utf-8",
		         data:'{"uploader":"${param.username}","projectname":"'+projectname+'","projecttext":"'+projecttext+'"}',
		         dataType:"json",
		         type:"post",
		         success:function(data){
		             if(data.message == "success"){
                         //close window
                         var iframes = window.parent.document.getElementsByTagName('iframe');
                          $(window.parent.document).find("div").css("opacity","1");
                          for( var i = 0;i < iframes.length; i++){
                                if(iframes[i].getAttribute('uuid')=='${param.uuid}')$(iframes[i]).suicide();
                          }
                      }
                      else{
                         $$.tips("message",null,{content:"Failed adding text to project",timeout:"3000",attachposition:"2"});
                      }
		         },
		         error: function(XMLHttpRequest, textStatus, errorThrown) {
                      $$.tips("message",null,{content:"Service error trying to add text",timeout:"3000",attachposition:"2"});
                 }
		     });
	    }
	});		
	$("#cancel").click(function(){
		var someIframe = window.parent.document.getElementsByTagName('iframe');
		$(window.parent.document).find("div").css("opacity","1");
		$(someIframe).css('display','none');
	});
});
	
	


</script>
</head>
<body>
<div id="title">Add Text/Description to Your Project</div>
<div id="form">
<form action="javascript:void(0)" method="post">
<textarea id="projecttext" cols="50" rows="10" placeholder="Add a Text" name="projecttext"></textarea><br>
  <div class='hd'>Project name:</div>
  <input class = 'content' id="projectname" list="projects" name="projectname" autocomplete="off"/>
  <datalist id="projects">
    <c:forEach var="projectName" items="${user.projectList}">
    <option value="${projectName}"/>
    </c:forEach>
  </datalist>
  <br>
  <input id="cancel" type="submit" value="cancel">
  <input id="submit" type="submit" value="submit">
</form>
</div>
</body>
</html>