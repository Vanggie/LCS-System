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
              <div class="mysetting-container-item" id="setpassword">
                  <p class="mysetting-password-head">To change passwotd , please enter your current password first</p>

                  <form class='edit-credential' action='javascript:void(0)' method='post'>
                  <table summary="个人资料" cellspacing="0" cellpadding="0" class="tfm">
                  <tbody><tr>
                  <th><span class="rq" title="必填">*</span>Old Password</th>
                  <td><input type="password" name="oldpassword" id="oldpassword" class="px"></td>
                  </tr>
                  <tr>
                  <th>New Password</th>
                  <td>
                  <input type="password" name="newpassword" id="newpassword" class="px">
                  <p class="d" id="chk_newpassword">If you are not going to change password, leave it blank </p>
                  </td>
                  </tr>
                  <tr>
                  <th>Confirm New Password</th>
                  <td>
                  <input type="password" name="newpassword2" id="newpassword2" class="px">
                  <p class="d" id="chk_newpassword2">If you are not going to change password, leave it blank </p>
                  </td>
                  </tr>
                  <tr id="contact">
                  <th>Email</th>
                  <td>
                  <input type="text" name="emailnew" id="emailnew" value="${user.email}" disabled="">
                  <p class="d">
                  <img src="static/image/common/mail_active.png" alt="Activated" class="vm"> <span class="xi1">Email activated</span>
                  </p>
                  <p class="d">To change email, password resetting links will be sent </p></td>
                  </tr>
                  <tr>
                  <th>Security Question</th>
                  <td>
                  <select name="questionidnew" id="questionidnew">
                  <option value="" selected="">Save Orignal Settings</option>
                  <option value="0">No Security Questions</option>
                  <option value="1">Mother's Name'</option>
                  <option value="2">Gradpa's name'</option>
                  <option value="3">In which city is your father born?</option>
                  <option value="4">Your most Love teacher's name</option>
                  <option value="5">PC Type</option>
                  <option value="6">Most favorate Restraunt</option>
                  <option value="7">Last four digits of DL</option>
                  </select>
                  <p class="d">Security Questions will be asked when you login the first time</p>
                  </td>
                  </tr>
                  <tr>
                  <th>Answer</th>
                  <td>
                  <input type="text" name="answernew" id="answernew" class="px">
                  <p class="d">Please enter your answer to security question </p>
                  </td>
                  </tr>
                  <tr>
                  <th>&nbsp;</th>
                  <td><button type="submit" name="pwdsubmit" value="true" class="pn pnc"><strong>Save</strong></button></td>
                  </tr>
                  </tbody></table>

                  </form>
              </div>
         </div>
     </div>
</body>