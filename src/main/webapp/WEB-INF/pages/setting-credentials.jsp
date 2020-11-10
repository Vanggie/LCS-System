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
<script type="text/javascript" src="js/settings.js?version=4"></script>
<link  rel="stylesheet" type="text/css" href="css/homepage.css?version=1"/>
<link  rel="stylesheet" type="text/css" href="css/personal.css?version=1"/>
<link  rel="stylesheet" type="text/css" href="css/setting.css?version=Math.random()"/>


</head>
<title>LCS, Communicate and share</title>
<body>
<div id="toolbar">
      <ul id="toolbar-left-list">
        <li id="toolbar-left-item">
            <img src="images/logo.png"/>
        </li>
        <li id="toolbar-left-item">
            <a href="login">Explore</a>
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
                  <li><a href="viewPersonal">Front Page</a></li>
                  <li><a>Status</a></li>
                  <li><a>History</a></li>
                  <li><a>Logs</a></li>
                  <li><a>Share</a></li>
                  <li><a>Settings</a></li>
              </ul>
          </div>
     </div>
     <div id="mysetting-container">
         <div id="mysetting-container-left">
             <div class="mysetting-container-item" id="Settingmenu">
                  <div id="mysetting-container-title">Settings</div>
                  <div id="mysetting-menu-container">
                      <ul id="mysetting-menu-list">
                            <li class="listitem mysetting-menu-list-item" id = "mysetting-face"><a href="viewSettings?mode=face">Face Photo</a></li>
                            <li class="listitem mysetting-menu-list-item" id = "mysetting-credentials"><a href="viewSettings?mode=credentials">Credentials</a></li>
                            <li class="listitem mysetting-menu-list-item" id = "mysetting-password"><a href="viewSettings?mode=password">Password Security</a></li>
                      <ul>
                  </div>
             </div>
         </div>
         <div id="mysetting-container-right">
              <div class="mysetting-container-item" id="setcredentials">
                  <form class='edit-credential' action='javascript:void(0)' method='post'>
                     <table class='mysetting-credential-table'>
                         <tbody>
                            <tr><th>Login ID: </th><td>${user.username}</td></tr>
                            <tr><th id='gender'>Gender:</th><td><select name="gender" id="gender" class="ps" tabindex="1"><option value="0" selected="selected">Secret</option><option value="1">Male</option><option value="2">Female</option></select></td></tr>
                            <script>
                                var gender = '${user.gender}';
                                if(gender == 'Secret'||gender == 'secret') $("select[id='gender']")[0].selectedIndex=0;
                                if(gender == 'Male'||gender == 'male') $("select[id='gender']")[0].selectedIndex=1;
                                if(gender == 'Female'||gender == 'female') $("select[id='gender']")[0].selectedIndex=2;
                            </script>
                            <tr><th id='email'>Email: </th><td><input id='email' name='email' type='text' value='${user.email}'/></td></tr>
                            <tr><th id='phone'>Phone: </th><td><input id='phone' type='text' name='phone' value='${user.phone}'/></td></tr>
                            <tr><th id='address'>Address: </th><td><input id='address' type='text' name='address' value='${user.address}'/></td></tr>
                            <tr>
                                <th>&nbsp;</th>
                                <td colspan="2">
                                    <input type="hidden" value="true">
                                    <button type="submit" id="profilesubmitbtn" value="true" class="credential-save"><strong>SAVE</strong></button>
                                    <span id="submit_result" class="rq"></span>
                                </td>
                            </tr>
                            <script>
                                //to submit form
                                $(".edit-credential").submit(function(){
                                    genderSelection = ['secret','male','female'];
                                    $trs = $(this).find('tr');
                                    JsonUserData='"username":"${user.username}",';
                                    for(var i = 0; i < $trs.length; i++){
                                        $input = $trs.eq(i).find('td').children();
                                        if($input.eq(0).attr('id') == 'gender'){
                                            JsonUserData = JsonUserData + '"'+$input.eq(0).attr('name')+'":"'+ genderSelection[$input[0].selectedIndex] +'",';
                                        }else{
                                            JsonUserData = JsonUserData + '"'+$input.eq(0).attr('name')+'":"'+ $input.eq(0).val() +'",';
                                        }
                                    }
                                    JsonUserData = JsonUserData.substring(0, JsonUserData.length - 1);
                                    JsonUserData = '{' + JsonUserData + '}';
                                    console.log(JsonUserData);
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
                            </script>
                         </tbody>
                     </table>
                  </form>
              </div>
         </div>
     </div>
</body>