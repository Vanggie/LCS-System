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
<link  rel="stylesheet" type="text/css" href="css/setting.css?version=5"/>


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
              <div class="mysetting-container-item" id="setfaceimage">
                  <form id="uploadfaceimage">
                      <table id="current-face-photo">
                          <caption>
                              <h2>My Current Face Photo</h2>
                              <p> Default photo is displayed if this is the first time setting your face photo</p>
                          </caption>
                          <tbody>
                              <tr>
                                  <td><img style="width:400px;" onerror="this.src='images/profile.png';" src='resource/userdata/${username}/face.jpg?t='+Math.random()/></td>
                              </tr>
                          </tbody>
                      </table>
                      <table id="new-face-photo">
                           <caption>
                                  <h2>Setting My Face Photo</h2>
                                  <p> Select a new photo from your local storage</p>
                           </caption>
                                 <tbody>
                                      <tr>
                                           <td>
                                           <input type="file" id="avatarfile" accept=".jpg,.png,.bmp,.gif,.jpeg" style="display:none;" onchange="readAsDataURL(this.files[0])">
                                           <div id="saya_avatar_box" class="saya_avatar_box">
                                                <div class="uploading" id="uploading">
                                                   <span style="display: inline-block;vertical-align: middle;line-height: 22px;">
                                                       <img src="images/uploading.gif"><br>
                                                       <strong>Uploading</strong>
                                                   </span>
                                                </div>
                                                <canvas id="select-file-canvas" class="saya_canvas_1" height="250" width="310">
                                                <span class='.tooltip-canvas-1' style="visibility: hidden;">drag image</span>
                                                </canvas>
                                                <div class="zoomBar" id="zoomControlBar">
                                                    <div class="zoomControl" id="zoomControl">
                                                        <span></span>
                                                    </div>
                                                </div>
                                                <div id="mark" class="mark" style="cursor: move;">
                                                    <div class="clipround" id="clipround"></div>
                                                    <div class="rdcontrol" id="rd"></div>
                                                </div>
                                                <canvas id="canvas3" class="saya_canvas3" height="80" width="80"></canvas>
                                                <div class="beforeselector" id="avatarselecter">
                                                     <strong>Click to select files <span class="can-drag-and-drop" style='display:none'>or drag file to here</span></strong>
                                                </div>
                                                <div class="reupload" id="avatarselecter" style="display:none;">
                                                     <strong>Reselect</strong>
                                                </div>
                                                <div class="uploadavatarbtn" id="uploadavatarbtn">
                                                     <strong>Confirm</strong>
                                                </div>
                                           </div>
                                           </td>
                                      </tr>
                                 </tbody>
                      </table>
                  </form>
             </div>
         </div>
     </div>
</body>