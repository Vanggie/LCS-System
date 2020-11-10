<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page language="java" import="com.lcs.domain.User"%>
<%@ page language="java" import="java.util.Map.*"%>
<%@ page language="java" import="java.util.Map"%>
<%@ page language="java" import="java.io.*"%>
<%@ page language="java" import="com.lcs.domain.Project"%>
<%@ page language="java" import="com.lcs.domain.Comment"%>
<%@ page language="java" import="com.lcs.domain.CommentList"%>

<c:set var="user"  value='${user}'></c:set>
<c:set var="projectMap"  value='${projectMap}'></c:set>
<c:set var="username" value='${user.username}'></c:set>
<c:set var="password" value='${user.password}'></c:set>
<c:if test="${username==null}">
Error!! Please Login First!!

</c:if>
<c:if test="${projectMap==null}">
<c:set var="message" value="project map don't load" scope="session"></c:set>
</c:if>
<!DOCTYPE html5>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="Expires" content="0">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache" content="no-cache">

<script type="text/javascript" src="js/jquery-2.2.4.js"></script>
<script type="text/javascript" src="js/layer/layer.js"></script>
<script type="text/javascript" src="js/jqjin/jqjin.js?version=5"></script>
<script type="text/javascript" src="js/homepage.js?version=4"></script>
<link  rel="stylesheet" type="text/css" href="css/homepage.css?version=48"/>
<script>
//global variables
var username = '${user.username}';
var projectMapJson = '${projectMapJson}';
var projectMap = JSON.parse(projectMapJson);
</script>



<title>LCS, Communicate and share</title>

</head>
<body id="itself">
    <div id="toolbar">
      <ul id="toolbar-left-list">
        <li id="toolbar-left-item">
            <img src="images/logo.png"/>
        </li>
        <li id="toolbar-left-item">
            <a href="#">Explore</a>
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
	<div id="container">
	<div class="container" id="container-left"></div>
	<div class="container" id="container-middle">
	<c:if test="${user.authority != 'Guest'}">
		<div id="nav">
			<div class="nav-faceimage-container">
				<img id="faceimage" onerror="this.src='images/profile.png';" src="resource/userdata/${user.username}/face.jpg?t="+Math.random()/>
			</div>
			<div class="navlist-container">
				<ul id="navlist">
					<li><img class = 'addFile' fileType = 'text' id="addText" src="images/text.jpg" /><br><span>Text</span></li>
					<li><img class = 'addFile' fileType = 'image' id="addImage" src="images/images2.jpg"/><br><span>Image</span></li>
					<li><img class = 'addFile' fileType = 'movie' id="addMovie" src="images/movie.jpg" /><br><span>Movie</span></li>
					<li><img class = 'addFile' fileType = 'attachment' id="addAttachment" src="images/attachment.jpg"/><br><span>Attachment</span></li>
					<li><img class = 'addFile' fileType = 'more' id="more" src="images/more.png"/><br><span>More</span></li>
				</ul>
			</div>
		</div>
	</c:if>

		<c:forEach var="project" items="${projectMap.entrySet()}">
		    <div class='project' id="${project.getKey()}">
				<div id="project-content">
				    <div id="project-title">
				         <div class='uploader-face'>
				            <img style="height:100%;width:auto" alt="${project.getValue().uploader}'s profile picture" class="_6q-tv" data-testid="user-avatar" draggable="false" src="resource/userdata/${project.getValue().uploader}/face.jpg"/>
				          </div>
				         <div class='text'>
				         <div class='uploader-name'>
				             ${project.getValue().uploader}
				         </div>
				         <div class='projectName'>
				             ${project.getKey()}
                         </div>
                         </div>
                         <div class="more">
                           <button class="more " type="button">
                            <div class="more ">
                             <div class="more" style="height: 24px; width: 24px;">
                                 <svg aria-label="more" class="more" fill="#262626" height="16" viewBox="0 0 48 48" width="16">
                                     <circle clip-rule="evenodd" cx="22" cy="24" fill-rule="evenodd" r="1.5"></circle>
                                     <circle clip-rule="evenodd" cx="30" cy="24" fill-rule="evenodd" r="1.5"></circle>
                                     <circle clip-rule="evenodd" cx="38" cy="24" fill-rule="evenodd" r="1.5"></circle>
                                 </svg>
                              </div>
                            </div>
                           </button>
                         </div>
				    </div>
					<div class="project-movpic" id="${project.getKey()}">
					    <c:if test="${project.getValue().mov > 0 || project.getValue().pic > 0}">
					    <div class="project-movpic-wrapper" id = "${project.getKey()}" style="position:relative;white-space: nowrap;">
					        <div class='file-menu' style='height:60px;white-space:nowrap;'>
					             <svg aria-label="more" class="more" fill="#0095F6" height="60" viewBox="0 0 48 16" width="20">
                                     <circle clip-rule="evenodd" cx="8" cy="24" fill-rule="evenodd" r="8"></circle>
                                 </svg>
					             <c:forEach var = "i" begin = "2" end = "${project.getValue().pic + project.getValue().mov}">
					             <svg aria-label="more" class="more" fill="#A8A8A8" height="60" viewBox="0 0 48 16" width="20">
                                       <circle clip-rule="evenodd" cx="8" cy="24" fill-rule="evenodd" r="8"></circle>
                                 </svg>
					             </c:forEach>

                        	</div>

                        	<div class = 'file-menu-move-right' id="${project.getValue().uploader}" style='cursor:hand;position:absolute;z-index:3;right:0px;top:40%;width:20px;height:20px;border:solid #BDC0CD 12px;border-radius:50%;background-color:#BDC0CD;opacity:0.6;'>
                                    <svg style="opacity:1" stroke="black" stroke-width="6" fill="none" height="100%" viewBox="0 0 32 32" width="100%">
                                          <path d="M 11,4 L 24,16 L 11,28" />
                                    </svg>
                            </div>
                            <script>
                                var projectFileWrapperNode = $("div[class=project-movpic-wrapper]");
                                var projectName = projectFileWrapperNode.attr('id');
                                if(projectMap[projectName].mov == 1)
                                {
                                    projectFileWrapperNode.find("div[id='movie-menu-move-right']").css('display', 'none');
                                }
                            </script>
                            <div class = 'file-menu-move-left' id="${project.getValue().uploader}" style='cursor:hand;display:none;position:absolute;z-index:3;left:0px;top:40%;width:20px;height:20px;border:solid #BDC0CD 12px;border-radius:50%;background-color:#BDC0CD;opacity:0.6;'>
                                    <svg style="opacity:1" stroke="black" stroke-width="6" fill="none" height="100%" viewBox="0 0 32 32" width="100%">
                                           <path d="M 24,4 L 11,16 L 24,28" />
                                    </svg>
                            </div>
                        	<div style="width:100%;align-items:center;display:-webkit-flex;">
                        	<c:if test = "${project.getValue().mov > 0}">
					            <video  style="z-index:1;" id="${project.getValue().uploader}" src = "resource/userdata/${project.getValue().uploader}/${project.getKey()}/movie/${project.getValue().firstMovName}" class = 'project-file' width='100%' controls>
                                  <source src="resource/userdata/${project.getValue().uploader}/${project.getKey()}/movie/${project.getValue().firstMovName}" type="video/mp4"/>
                                  <script>
                                     var videoNode = $("video[class='project-file']");
                                     var src = videoNode.attr('src');
                                     if(src.endsWith(".mp4")||src.endsWith(".MP4"))
                                     {
                                        videoNode.find("source").attr('type', 'mp4');
                                     }
                                     else{
                                        videoNode.find("source").attr('type', 'ogg');
                                     }
                                     videoNode.parent().css('min-height',videoNode.height());
                                  </script>
                               </video>
                            </c:if>
                            <c:if test = "${project.getValue().pic > 0}">
                               <img class='project-file' id="${project.getValue().uploader}" src="resource/userdata/${project.getValue().uploader}/${project.getKey()}/image/${project.getValue().firstPicName}"/>
                               <script>
                                  if(projectMap[projectName].mov > 0)
                                  {
                                         projectFileWrapperNode.find("img[class='project-file']").css('display', 'none');
                                  }
                               </script>
                            </c:if>
                            </div>
                        </div>
						</c:if>
					</div>
					<div class="projecttext-container">
						<c:if test="${project.getValue().text>0}">
							<ul class='project-text'>
							    <li class='username' id="${project.getValue().uploader}">
							    Uploader: ${project.getValue().uploader}
							    </li>
							    <c:if test="${firstProjectTextMap.containsKey(project.getKey())}">
							        <li class='username' id="${project.getValue().uploader} firstTextDescription">
                                	     ${firstProjectTextMap.get(project.getKey())}
                                	</li>
							    </c:if>
							    <img id='moretext' src='images/ellipse.png'/>
							</ul>
						</c:if>
					</div>
				</div>
                <table class='projectfoot' id="${project.getKey()}">
                <tbody>
                     <tr id="${project.getValue().uploader}">
                        <td><img class='project-interact' id='projectcomment' src="images/comment.jpg"
								alt="Comment"/> <a id="comment"
								style="float: right"> C </a></td>
						<td><img class='project-interact' id='projectthumbup' src="images/thumbUp.png" alt="thumbUp"/>
								<a style="float:right">(${project.getValue().thumbUp})</a></td>
						<c:if test="${user.authority != 'Guest'}">
						<td><img class='project-interact' id='projectdownload' src="images/download.png" alt="download"
								/> <a id="download" style="float: right"> D </a></td>
						</c:if>
						<c:if test="${user.username == project.getValue().uploader}">
						<td><img class='project-interact' id='project-update' src="images/update.png" alt="update"
                        								/> <a id="update" style="float: right"> U </a></td>
                        </c:if>
                     </tr>
                </tbody>
                </table>
			</div>
		</c:forEach>
		<div class="container-pageNav">
		     <table>
		       <tbody>
		         <tr>
		           <td class="previous-page"><a><</a></td>
		           <c:forEach var = "i" begin = "${startPageNum}" end = "${5 + startPageNum - 1}">
                        <c:if test="${curPageNum == i && i <= numOfPages}">
                              <td class='page-button' style="cursor:default;background-color:#337AB7;color:white;"><a>${i}</a></td>
                        </c:if>
                        <c:if test="${curPageNum != i && i <= numOfPages}">
                              <td class='page-button'><a>${i}</a></td>
                        </c:if>
                    </c:forEach>
                    <td class="previous-page"><a>></a></td>
                  </tr>
               </tbody>
             </table>
		</div>
	</div>
	<div class="container" id="container-right"></div>
	</div>
</body>
</html>