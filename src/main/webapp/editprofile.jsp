<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="com.lcs.domain.User" %>
<%@ page language="java" import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="pragma" content="no-cache"> 
<meta http-equiv="cache-control" content="no-cache"> 
<meta http-equiv="expires" content="0">
<html>
<head>
<script type="text/javascript" src="js/jquery-2.2.4.js"></script>
<script type="text/javascript" src="js/jquery-2.2.4.js"></script>
<script type="text/javascript" src="js/layer/layer.js"></script>
<script type="text/javascript" src="js/jqjin/jqjin.js"></script>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

<title>Personal Profile</title>
<style>
   #faceimage
   {
      margin:auto;
      float:left;
      cursor:pointer;
   }
   #personalinfo
   {
      float:left;
      margin:0.5em;
      cursor:pointer;
      height:110px;
      width:110px;
   }
   #personalinfo li
   {
     font-size:1.1em;
     font-family:times new roman;
     color:black;
     cursor:pointer;
 
   }
   #ResearchArea
   {
      clear:both;
      margin:auto;
      font-weight:italic;
      cursor:pointer;
   }
   .inteterestArea-list,
   .inteterestArea-add
   {
     margin:5px;
     height:110px;
     width:110px;
     float:left;
     border:solid gray 3px;
     display:inline;
     font-size:1.1em;
     font-family:times new roman;
     color:green;
     cursor:pointer;
   }
   button:hover
   {
      background-color:#529ECC;
      cursor :pointer;
   }
</style>
<script>
function showeditoption(li)
{  
   link=li.getElementsByTagName('a');
   for(var i=0;link!=null && i<link.length;i++)
   {
	   if(link[i].id=="editlink")
	   {
		   img=link[i].getElementsByTagName('img');
		   for(var j=0;img!=null && j<img.length;j++)
			{
		    img[j].src="images/edit.jpg";
			img[j].id="edit";
			img[j].width=30;
			img[j].height=30;
			
			}
	   }
	   if(link[i].id=="savelink")
	   {
		    img=link[i].getElementsByTagName('img');
		    for(var j=0;img!=null && j<img.length;j++)
			{
		    
			img[j].src="images/save.jpg";
			img[j].id="save";
			img[j].width = 30;
			img[j].height=30;
			
			}
			
	   }
	   if(link[i].id=="deletelink")
	   {
		    img=link[i].getElementsByTagName('img');
		    for(var j=0;img!=null && j<img.length;j++)
			{
		    
			img[j].src="images/delete.png";
			img[j].id="delete";
			img[j].width = 30;
			img[j].height=30;
			img[j].onclick="DeleteInterestArea(this)";
			}
			
	   }
	}
   
}
function removeeditoption(li)
{

	link=li.getElementsByTagName('a');
	for(var i=0;link!=null && i<link.length;i++)
	   { 
		   if(link[i].id=="editlink")
		   {
			    img=link[i].getElementsByTagName('img');
			    for(var j=0;img!=null && j<img.length;j++)
				{
			    	img[j].src="#";
					
					img[j].width=0;
					img[j].height=0;
					
				}
			 }
		   if(link[i].id=="savelink")
		   {
			    img=link[i].getElementsByTagName('img');
			    for(var j=0;img!=null && j<img.length;j++)
				{
			    	img[j].src="#";
					
					img[j].width=0;
					img[j].height=0;
				}
		   }
		   if(link[i].id=="deletelink")
		   {
			    img=link[i].getElementsByTagName('img');
			    for(var j=0;img!=null && j<img.length;j++)
				{
			    	img[j].src="#";
					
					img[j].width=0;
					img[j].height=0;
				}
		   }
		}
	
}
function editprofile(a)
{
	//Delete text in span list;
	span = a.parentNode.getElementsByTagName('span');
    for(var i=0;span!=null && i<span.length; i++)
	{
    	span[i].innerHTML="";
	 
	}
    //show form input;
    input = a.parentNode.getElementsByTagName('input');
    for(var i=0;input!=null && i<input.length; i++)
	{
    	if(input[i].type=='hidden'&&input[i].type!='text')
    	{
    		input[i].type='text';
    	}
    	
	
	}
}
function saveprofile(a)
{
	form=document.getElementById("formPersonalInfo");
	form.action="saveProfile";
	form.method="get";
	form.submit();
}
function deleteprofile(a)
{
	//Delete li;
	li = a.parentNode;
	li.parentNode.removeChild(li); 
}

function addInterestArea(img)
{
	liAdd=img.parentNode.parentNode;
	var remarks = ${param.remarks};
    var remarksArray = remarks.split(',');
    var NumInterest = remarksArray.length;
	NumInterest = NumInterest + 1;
	var newIndex = NumInterest - 1;
	newLi = $("<li class = 'inteterestArea-list index="+ newIndex +"'></li>");
	newliHTML="<div style='height:80px;width:80px;border:red;'>"+
	      "<span></span>"+
	     "<input type='text'size='13' name='interestArea' value='Type In'/>"+
		"</div>"+
		"<a id='editlink' onclick='editprofile(this)'><img/></a>"+
		"<a id='savelink'"+
		"onclick='saveprofile(this)'><img/></a>"+
		"<a id='deletelink' onclick='deleteprofile(this)'><img/></a>";
	newLi.innerHTML = newliHTML;
	liAdd.before(newLi);

}
function uploadface(img)
{
	if($("input[id='uploadface']").attr('type')!='file')
	{
		img.src='resource/upload.jpg';
		img.width=200;
		img.height=200;
		input=img.parentNode.getElementsByTagName("input");
		input[0].type="file";
		var button1=$("<button id='uploadface' disabled='disabled' onclick='uploadfacesubmit(this)' style='border-style:ridge;position:relative;left:-5px;top:-120px;width:70px;height:30px;color:gray;font-size:18px;font-family:times new roman'>Upload</button>");
		$("input[id='uploadface']").after(button1);
		var button2=$("<button id='deletefile' onclick='uploadfacedelete(this)' style='position:relative;left:0px;top:-120px;width:70px;height:30px;color:black;font-size:18px;font-family:times new roman'>Delete</button>");
		button1.after(button2);
		$("iframe[id='uploadStatusFrame']").css("display","block");
	}

}

function uploadfacesubmit(button)
{
	if($("input[id='uploadface']").val()!=null&&$("input[id='uploadface']").val()!='')
	{
		
		$("form[id='uploadfaceform']").submit(function(){
			//$$.msg("Upload Status",$("input[id='uploadface']"),{timeout:5000,content:"${message}"});
			// $$.tips(null,$("input[id='uploadface']"),{timeout:7000,content:"${message}"});
			//location.reload();
			$("button[id='uploadconfirm']").css('display','block');
			
		});
		window.location.reload();
		
	}
	
			
}
function uploadfacedelete(button)
{
	$("input[id='uploadface']").val('');
			
}
function recoverface(div)
{
	//img=div.getElementsByTagName("img");
	//img[0].src="./resource/userdata/"+username+"/face.jpg";
	//img[0].width=200;
	//img[0].height=200;
	//input=div.getElementsByTagName("input");
	//input[0].type="hidden";
	
}

$(document).ready(function(){
    var remarks = "${param.remarks}";
    remarksArray = remarks.split(",");
    if(remarksArray.length == 0){
          $(".inteterestArea-list").css('display','none');
    }
    else{
        $(".inteterestArea-list").eq(0).find(".textNode").text(remarksArray[0]);
        for(var i = 1; i < remarksArray.length; i++)
        {
           //new li createElement
           newLi = $("<li class = 'inteterestArea-list index="+ i +"'></li>");
           newLi.innerHTML = $(".inteterestArea-list").eq( i - 1).innerHTML;
           $(".inteterestArea-list").eq(i - 1).after(newLi);
        }
    }



	$("input[id='uploadface']").mouseleave(function(){
	
	if($("input[id='uploadface']").val()!=null&&$("input[id='uploadface']").val()!='')
	{
		$("button[id='uploadface']").removeAttr('disabled');
		$("button[id='uploadface']").css('border-style','outset');
		$("button[id='uploadface']").css('color','black');
		$("button[id='uploadface']").mouseover(function() {
			  $( this ).css('background-color','#529ECC');
			  
	    });
		$("button[id='uploadface']").mouseout(function() {
			  $( this ).css('background-color','#EBEBEB');
			  
	    });
		
	}
	else
	{
		$("button[id='uploadface']").attr('disabled','disabled');
		$("button[id='uploadface']").css('border-style','ridge');
		$("button[id='uploadface']").mouseover(function() {
			  $( this ).css('background-color','#EBEBEB');
			  
	    });
		$("button[id='uploadface']").mouseout(function() {
			  $( this ).css('background-color','#529ECC');
			  
	    });
	}
});
	});
</script>



</head>
<body>
<div style="height:200px;width:200px;text-align:center;float:left;" onmouseout="recoverface(this)">
<img id="faceimage" style='height:200px;width:200px;'src="resource/userdata/${param.username}/face.jpg" onclick="uploadface(this)" />
<form action="uploadface?username=${param.username}" id="uploadfaceform" name="uploadfaceform" encType="multipart/form-data"  method="post" target="hidden_frame">
<input type="hidden" id='uploadface' name="fileName" value="#" style='position:relative;left:0px;top:-150px;width:150px;height:30px;color:red;'/>
<iframe name='hidden_frame' id="uploadStatusFrame" scrolling='no' style='border:none;font-size:15px;display:block;position:relative;left:20px;top:-170px;width:150px;height:35px;color:red;'>
</iframe>
<button id='uploadconfirm' action='location.reload()' style='display:none;position:relative;left:55px;top:-170px;width:70px;height:30px;color:black;font-size:18px;font-family:times new roman'>Confirm</button>

</form>
</div>

<form id="formPersonalInfo">
<div>

<ul id="personalinfo" onmouseover="showeditoption(this)" onmouseout="removeeditoption(this)">
<li id="username">Name:     <span><a href="#">${param.username} </a></span><input name='username' type='hidden' value='${param.username}'/></li>
<li id="email">Email:     <span>${param.email}</span><input name='email' type='hidden' value='${param.email}%>'/></li>
<li id="phone">Phone:     <span>${param.phone}</span><input name='phone' type='hidden' value='${param.phone}%>'/></li>
<li id="address">Address:   <span>${param.address}</span><input name='address' type='hidden' value='${param.address}'/></li>
<a id='editlink' onclick="editprofile(this)"><img/></a><a id='savelink' onclick='saveprofile(this)'><img/></a>
</ul>

</div>
<div style="clear:both">
<p style="font-size:1.5em;color:blue;font-weight:bold;margin:auto;text-align:center;cursor:pointer;">Area of Interest</p>


<ul id="ResearhArea">
    <li class='inteterestArea-list index=0' onmouseover='showeditoption(this)' onmouseout='removeeditoption(this)'>
      <div style='height:80px;width:80px;border:red;'>
        <span class="textNode"></span>
        <input type='hidden'size='13' name='interestArea' value="${remarksArray[i]}"/>
      </div>
      <a id='editlink' onclick='editprofile(this)'><img/></a>
      <a id='savelink' onclick='saveprofile(this)'><img/></a>
      <a id='deletelink' onclick='deleteprofile(this)'><img/></a>
    </li>
<li class='inteterestArea-add'>
<div style="height:110px;width:110px;border:red;">
<img src="images/more2.jpg" onclick='addInterestArea(this)' style='width:110px;height:110px;'/>
</div>
</li>
</ul>

</div>
</form>
</body>
</html>