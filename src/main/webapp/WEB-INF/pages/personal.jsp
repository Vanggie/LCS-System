<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page language="java" import="com.lcs.domain.User"%>
<%@ page language="java" import="java.util.Map.*"%>
<%@ page language="java" import="java.util.Map"%>
<%@ page language="java" import="java.io.*"%>
<c:set var="username" value='${user.username}'></c:set>

<!DOCTYPE html5>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="pragma" content="no-cache"> 
<meta http-equiv="cache-control" content="no-cache"> 
<meta http-equiv="expires" content="0">
<script type="text/javascript" src="js/jquery-2.2.4.js"></script>
<script type="text/javascript" src="js/layer/layer.js"></script>
<script type="text/javascript" src="js/jqjin/jqjin.js"></script>
<link  rel="stylesheet" type="text/css" href="css/homepage.css?version=1"/>
<link  rel="stylesheet" type="text/css" href="css/personal.css?version=1"/>

<script>
$(document).ready(function(){
      $("a[id='edit-my-credentials']").click(function(){
          var credentialContentsNode = $('#my-credentials-content ul li');
          for(var i = 1; i < credentialContentsNode.length; i++)
          {
              credentialContentsNode.eq(i).children("span").css('display','none');
              credentialContentsNode.eq(i).children("input").css('display','block');
              credentialContentsNode.eq(i).children("select").css('display','block');
          }
          saveNode = $("<img id = 'save-credentials' style='width:20px;margin-left:4px;cursor:hand;' src='images/save.jpg'/>")
          cancelNode = $("<img id = 'cancel-credentials' style='width:20px;margin-left:4px;cursor:hand;' src='images/close.jpg'/>");
          $(this).parent().append(cancelNode);
          $(this).parent().append(saveNode);
          $(this).css('display','none');

          $("img[id='cancel-credentials'").click(function(){
              var credentialContentsNode = $('#my-credentials-content ul li');
              for(var i = 1; i < credentialContentsNode.length; i++)
              {
                     credentialContentsNode.eq(i).children("span").css('display','block');
                     credentialContentsNode.eq(i).children("input").css('display','none');
                     credentialContentsNode.eq(i).children("select").css('display','none');
              }
              $(this).css('display','none');
              $("img[id='save-credentials']").css('display','none');
              $("a[id='edit-my-credentials']").css('display','block');
          });

           $("img[id='save-credentials'").click(function(){
              var credentialContentsNode = $('#my-credentials-content ul li');
              var JsonUserData = '"username":"${user.username}",';
              genderSelection = ['secret','male','female'];
              for(var i = 1; i < credentialContentsNode.length; i++)
              {
                     var dataNode = credentialContentsNode.eq(i).children("select");
                     if(dataNode.length != 0)
                     {
                         JsonUserData = JsonUserData + '"'+dataNode.attr('name')+'":"'+
                         genderSelection[dataNode[0].selectedIndex] +'",';
                     }
                     dataNode = credentialContentsNode.eq(i).children("input").eq(0);
                     if(dataNode.length != 0)
                     {
                         JsonUserData = JsonUserData + '"'+dataNode.attr('name')+'":"'+
                         dataNode.val() +'",';
                     }
                     credentialContentsNode.eq(i).children("span").css('display','block');
                     credentialContentsNode.eq(i).children("input").css('display','none');
                     credentialContentsNode.eq(i).children("select").css('display','none');

              }
              JsonUserData = JsonUserData.substring(0, JsonUserData.length - 1);
              JsonUserData = '{' + JsonUserData + '}';
              console.log(JsonUserData);
              $(this).css('display','none');
              $("img[id='save-credentials']").css('display','none');
              $("img[id='cancel-credentials']").css('display','none');
              $("a[id='edit-my-credentials']").css('display','block');
              $.ajax({
              		         url:"editProfile",
              		         contentType:"application/json;charset=utf-8",
              		         data:JsonUserData,
              		         dataType:"json",
              		         type:"post",
              		         success:function(data){

              		         }
              });
           });
      });

});
</script>

</head>
<title>LCS, Communicate and share</title>
<body>
<div id="toolbar">
      <ul id="toolbar-left-list">
        <li id="toolbar-left-item">
            <img src="images/logo.png"/>
        </li>
        <li id="toolbar-left-item">
            <a href="index.html">Explore</a>
        </li>
        <li id="toolbar-left-item">
            <a href="#">My Projects</a>
        </li>
        <li id="toolbar-left-item">
             <a href="#">New Project</a>
        </li>
        <li id="toolbar-left-item">
            <a href="#">Feedback</a>
        </li>
        <c:if test="${user.authority == 'Admin'}">
                   <li id="toolbar-left-item">
                         <a href="#">Manage</a>
                   </li>
        </c:if>
      </ul>

      <div id="toolbar-container-right">
        <ul id="toolbar-right-list">
         <li id="toolbar-right-item">
                    <img id='idimg' src="images/profile.png" alt="${user.username}"/>
         </li>
         <li id="toolbar-right-item">
               <form id="search-form">
                     <input type="text" name="search" value="Search LCS"/>
               </form>
         </li>
        </ul>
      </div>
    </div>
     <div id="hd-container">
          <h2 id="spaceInfoShow"><strong>${username}'s space</strong></h2>
          <div id = "nav">
              <ul>
                  <li><a>Front Page</a></li>
                  <li><a>Status</a></li>
                  <li><a>History</a></li>
                  <li><a>Logs</a></li>
                  <li><a>Share</a></li>
                  <li><a href='viewSettings?mode=face'>Settings</a></li>
              </ul>
          </div>
     </div>
     <div id="myspace-container">
         <div id="myspace-container-left">
             <div class="myspace-container-item" id="profile">
                  <div id="myspace-container-title">Face Photo</div>
                  <div id="profile-img-container">
                      <img onerror="this.src='images/profile.png';" src="resource/userdata/${username}/face.jpg?t="+Math.random()/>
                      <ul id="profile-edit-list">
                            <li class="listitem profile-edit-list-item" id = "edit-face"><a href="viewSettings?mode=face">Edit Face</a></li>
                            <li class="listitem profile-edit-list-item" id = "edit-credentials"><a href="viewSettings?mode=credentials">Edit Credentials</a></li>
                      <ul>
                  </div>
             </div>
             <div class="myspace-container-item" id="myproject">
                   <div id="myspace-container-title">My Project</div>
                   <div id="myproject-list-container">
                         <ul id="myproject-edit-list">
                               <li class="listitem myproject-list-item"><a href="#">Omni3D Directional integrations</a></li>
                               <li class="listitem myproject-list-item"><a href="#">Omni2D</a></li>
                         <ul>
                   </div>
             </div>
             <div class="myspace-container-item" id="myproject">
                    <div id="myspace-container-title">Status Logs</div>
                    <div id="mystatus-list-container">
                          <ul id="mystatus-edit-list">
                                 <li class="listitem mystatus-list-item"><a href="#">Hello</a></li>
                                 <li class="listitem mystatus-list-item"><a href="#">Say some thing</a></li>
                          <ul>
                    </div>
             </div>
             <div class="myspace-container-item" id="myhistory">
                    <div id="myspace-container-title">History</div>
                    <div id="myhistory-list-container">
                          <ul id="myhistory-edit-list">
                                 <li class="listitem myhistory-list-item"><a href="#">Hello</a></li>
                                 <li class="listitem myhistory-list-item"><a href="#">Say some thing</a></li>
                          <ul>
                    </div>
             </div>
         </div>
         <div id="myspace-container-middle">
             <div class="myspace-container-item" id="mycredential">
                   <div id="myspace-container-title"><span>My Credentials</span><span id="edit-my-credentials" style="float:right;"><a id = "edit-my-credentials" href='javascript:void(0)'>Edit My Credentials</a></span></div>
                   <div id="my-credentials-content">
                         <ul>
                             <li><em>Username:</em><span>${user.username}</span></li>
                             <li><em>Gender:</em><span>${user.gender}</span>
                                 <select name="gender" id="gender" class="ps" tabindex="1" style="display:none">
                                     <option value="0" selected="selected">Secret</option>
                                     <option value="1">Male</option>
                                     <option value="2">Female</option>
                                 </select>
                             </li>
                             <script>
                                      var gender = '${user.gender}';
                                      if(gender == 'Secret'||gender == 'secret') $("select[id='gender']")[0].selectedIndex=0;
                                      if(gender == 'Male'||gender == 'male') $("select[id='gender']")[0].selectedIndex=1;
                                      if(gender == 'Female'||gender == 'female') $("select[id='gender']")[0].selectedIndex=2;
                             </script>
                             <li><em>Email:</em><span>${user.email}</span><input id='email' name='email' type='text' value='${user.email}' style="display:none"/></li>
                             <li><em>Phone:</em><span>${user.phone}</span><input id='phone' type='text' name='phone' value='${user.phone}' style="display:none"/></li>
                             <li><em>Address:</em><span>${user.address}</span><input id='address' type='text' name='address' value='${user.address}' style="display:none"/></li>
                         </ul>
                   </div>
             </div>
             <div class="myspace-container-item" id="status">
                   <div id="myspace-container-title">Status</div>
                   <div id="my-status-content">
                         <ul>
                               <li>No Status Posted, add one</li>
                         </ul>
                   </div>
             </div>
             <div class="myspace-container-item" id="share">
                    <div id="myspace-container-title">My Share</div>
                    <div id="my-share-content">
                         <ul>
                                <li>Share you link here</li>
                         </ul>
                    </div>
             </div>
             <div class="myspace-container-item" id="logs">
                    <div id="myspace-container-title">My Logs</div>
                    <div id="my-logs-content">
                         <ul>
                                <li>Post your logs here</li>
                         </ul>
                    </div>
             </div>
         </div>

         <div id="myspace-container-right">
             <div class="myspace-container-item" id="friends">
                   <div id="myspace-container-title">My Friends</div>
                   <div id="my-friendscontent">
                         <ul>
                                <li>List of friends</li>
                         </ul>
                   </div>
             </div>
             <div class="myspace-container-item" id="visitors">
                   <div id="myspace-container-title">My Visitors</div>
                   <div id="my-visitors">
                         <ul>
                                <li>List of visitors</li>
                         </ul>
                   </div>
             </div>
         </div>
     </div>
</body>