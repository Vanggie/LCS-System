    /////////////////////////////Global variables/////////////////////////////
	var myWinTextMore=new Map();
	var numFileToShowMax = 9; //the maximum number of images/movies to show on the image menu..
    //click add file in the navigation panel, will pop up iframes
	var iFrameWinMap = new Map(
                [['addText', null],
                ['addImage', null],
                ['addMovie', null],
                ['addAttachment',null]]
     )
    var iFrameUuidMap = new Map([
        ['addText', null],
        ['addImage', null],
        ['addMovie', null],
        ['addAttachment',null]
    ]);
    var numCommentToShow = 2;
	//////////////////////////////////////////////////////////////////////////


	////functions to callback the projectfoot options;
	$(document).ready(function(){
		   //adjust layout
		   // if($(".project-text").height()>$(".project-movpic").height())
		  // {

			   $(".project-movpic").css("width","100%");

			   $(".project-text").css("width","95%");

		 //  }

		   //resize function.
		   $( window ).resize(function() {
			  $( "#log" ).append( "<div>Handler for .resize() called.</div>" );
			});



		  //For Search, when clicked, text inside will disappear.
		  $("input[name='search']").focus(function(){
			  $(this).val('');
		  });
		  $("img[id='idimg']").click(function(){
		      window.location = 'viewPersonal';
		  });
          $("img[class='addFile']").click(function(event){
                var fileType = $(this).attr('fileType');
                if (fileType == 'text'){
                   url = 'addText.jsp?username=' + username;
                }
                else
                {
                   url = 'addImageOrMovieOrAttachment.jsp?fileType='+ fileType +'&username=' + username;
                }
                if (iFrameWinMap.get(fileType) == null){
                       iFrameUuidMap.set(fileType, Math.random());
                       url = url + "&uuid=" + iFrameUuidMap.get(fileType);
                       iFrameWinMap.set(fileType,
                       $$.iframe(iFrameUuidMap.get(fileType) , $(this),{offsetx:"40%",offsety:"20%"},{src:url,showbg:"0"},{"background-color":"white","height":"300px","width":"500px"})
                       );
                }else{
                      iFrameWinMap.get(fileType).fadeIn();
                }
                $("body").find("div").css("opacity","0.3");
          });

		  //move to next movie/image
		  $("div[class='file-menu-move-right']").click(function(event){
		      var fileType = $(this).attr('class').replace('-menu-move-right', '');
		      var projectFileNode = $(this).parent();
			  var projectName = projectFileNode.attr("id");
			  var uploader = $(this).attr("id");
			  var divFileMenu =  projectFileNode.children("div[class='file-menu']");
			  var displayedFileNodes = projectFileNode.find("[class=project-file]");
			  var displayedFileNode;
			  var displayedFileSrc;
			  for(var i = 0; i < displayedFileNodes.length ; i++){
			      if(displayedFileNodes.eq(i).css('display') != "none"){
			         displayedFileNode = displayedFileNodes.eq(i);
			         displayedFileSrc = displayedFileNode.attr('src');
			         break;
			      }
			  }

			  var displayedFileId;
			  var firstTimeShow = divFileMenu.find("img[class='menu-item']").length == 0;//no menu items yet
			  var fileNamesStr ='';
			  fileTypes = ['movie', 'image'];
			  var movieNames;
			  var imageNames;

			  if(firstTimeShow){
			           //get data
			           $.ajax({
			              type: "post",
                          url: "getProjectFileNames",
                          async: true,//!important, since following scripts are executed after ajax, need to sed it as sync.
                          data:'{"uploader":"' + uploader +'","projectName":"'+projectName+'","fileType":"' + fileTypes[0] + '"}',
                          dataType:"json",
                          cache: false,
                          contentType:"application/json;charset=utf-8",
                          processData: false,
                          timeout: 60000,
                          success: function (data) {
                               movieNames = data.fileNames;
                               $.ajax({
                              		type: "post",
                                    url: "getProjectFileNames",
                                    async: true,//!important, since following scripts are executed after ajax, need to sed it as sync.
                                    data:'{"uploader":"' + uploader +'","projectName":"'+projectName+'","fileType":"' + fileTypes[1] + '"}',
                                    dataType:"json",
                                    cache: false,
                                    contentType:"application/json;charset=utf-8",
                                    processData: false,
                                    timeout: 60000,
                                    success:function(data){
                                       imageNames = data.fileNames;
                                       var fileNames = movieNames.concat(imageNames);
                                       for(var i = 0 ; i < fileNames.length; i++){
                                                fileNamesStr = fileNamesStr + fileNames[i] + "/";
                                       }
                                       fileNamesStr = fileNamesStr.substring(0, fileNamesStr.length - 1);
                                       divFileMenu.attr('id', fileNamesStr);
                                       console.log("Success getProjectFileNames: data: " + fileNames);
                                       var fileNames = fileNamesStr.split("/");
                                       var NumOfFiles = fileNames.length;
                                       var fileIndStart = 0;
                                       var fileIndEnd = NumOfFiles - 1;
                                       //generate and display file menu preview
                                       divFileMenu.html("");
                                       divFileMenu.css('overflow','auto');

                                       var moviePlayerMark = $('<svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"'+
                                                               	 'width="472.366px" height="472.366px" viewBox="0 0 472.366 472.366" style="enable-background:new 0 0 472.366 472.366;"'+
                                                               	 'xml:space="preserve" stroke="black" stroke-width="7" fill="black">'+
                                                               '<g>'+
                                                               	'<path d="M137.964,359.598c-1.727,0-3.453-0.447-5-1.34c-3.094-1.787-5-5.089-5-8.66V122.77c0-3.572,1.906-6.874,5-8.66'+
                                                               		'c3.094-1.787,6.906-1.787,10,0l196.438,113.414c3.095,1.786,5,5.088,5,8.66s-1.905,6.875-5,8.66L142.964,358.258'+
                                                               		'C141.417,359.151,139.69,359.598,137.964,359.598z M147.964,140.09v192.188l166.438-96.093L147.964,140.09z"/>'+

                                                               '</g>'+
                                                               '</svg>');

                                       moviePlayerMark.css('position','absolute');
                                       moviePlayerMark.css('width','20px');
                                       moviePlayerMark.css('height','20px');
                                       var left = -8;
                                       for(var curFileInd = fileIndEnd; firstTimeShow && curFileInd >= fileIndStart; curFileInd--)
                                       {
                                                  var filename = fileNames[curFileInd];
                                                  var fileMenuItemNode = $("<img class='menu-item' id='"+ curFileInd +"'>");
                                                  fileMenuItemNode.css('display','inline-block');
                                                  fileMenuItemNode.css('width','9%');
                                                  fileMenuItemNode.css('opacity','0.6');
                                                  fileMenuItemNode.css('height','90%');
                                                  var fileType = curFileInd < movieNames.length ? "movie" : "image";

                                                  src = "resource/userdata/"+uploader+"/" + projectName + "/"+ fileType +"/"+filename;
                                                  if(curFileInd < movieNames.length)
                                                  {
                                                      src = src + ".png";
                                                      fileMenuItemNode.attr('src', src);
                                                      divFileMenu.prepend(fileMenuItemNode);
                                                      divFileMenu.prepend(moviePlayerMark);
                                                      moviePlayerMark.css('top', '15px');
                                                      left = left + fileMenuItemNode.width()/2;
                                                      moviePlayerMark.css('left', left + "px" );
                                                      left = left + fileMenuItemNode.width()/2;
                                                      console.log(fileMenuItemNode.width());
                                                      moviePlayerMark = moviePlayerMark.clone();
                                                  }
                                                  else{
                                                       fileMenuItemNode.attr('src', src);
                                                       divFileMenu.prepend(fileMenuItemNode);
                                                  }

                                       }
                                       doMoveToNext();
                                    }
                               });
                          },
                          error:function(data, textStatus, errorThrown){
                              console.log(errorThrown);
                          },
                          complete:function(){

                          }

                       });
              }
              else{
                  doMoveToNext();
              }
              //now address the move right operations
              //dom nodes updated, need to redo the query.
              function doMoveToNext()
              {

                   var numOfMovies = projectMap[projectName].mov;
                   //display move left option
                   divFileMenu.parent().find("[class=file-menu-move-left]").css('display' , 'block');

                   var displayedFileId = parseInt(displayedFileSrc.match(new RegExp("(image|movie)" + "[0-9]+."))[0].match(/[0-9]+/g)[0]) - 1;
                   var displayedFileType = displayedFileSrc.match(new RegExp("(image|movie)" + "[0-9]+."))[0].match(/image|movie/g)[0];
                   var numOfMovies = divFileMenu.attr('id').match(/movie/g).length;
                   displayedFileId = displayedFileType == "movie" ? displayedFileId : displayedFileId + numOfMovies;
                   //switch clickedSrc and displayedSrc
                   switchClickedAndDisplayed(displayedFileNode, divFileMenu, displayedFileId + 1);
                   //check whether we are reaching the last image, if yes, hide the move-right icon
                   if(displayedFileId + 1 == fileIndEnd ){
                       divFileMenu.parent().find("[class=file-menu-move-right]").css('display' , 'none');
                   }


                   //write callback functio==ions for clicking on the menu items
                   $("img[class='menu-item']").click(function(){
                       var numOfMovies = projectMap[projectName].mov;
                       var projectFileNode = $(this).parent().parent();
                       var divFileMenu =  $(this).parent();
                       var displayedFileNodes = projectFileNode.find("[class=project-file]");
                       var displayedFileNode;
                       var displayedFileSrc;
                       for(var i = 0;  i < displayedFileNodes.length ; i++){
                           if(displayedFileNodes.eq(i).css('display') != "none"){
                              displayedFileNode = displayedFileNodes.eq(i);
                              displayedFileSrc = displayedFileNode.attr('src');
                              break;
                           }
                       }
                       clickedFileSrc = $(this).attr('src');
                       clickedFileType = clickedFileSrc.match(new RegExp("(image|movie)" + "[0-9]+."))[0].match(/image|movie/g)[0];
                       var clickedFileId = $(this).attr('id');
                       switchClickedAndDisplayed(displayedFileNode, divFileMenu, clickedFileId);
                   });
              }
          });

          function switchClickedAndDisplayed(displayedFileNode, divFileMenu, clickedFileId){
              //switch clickedSrc and displayedSrc
              var imgNodes = divFileMenu.find("img");
              var displayedFileSrc = displayedFileNode.attr('src');
              fileIndStart = 0;
              fileIndEnd = imgNodes.length - 1;
              displayedFileId = parseInt(displayedFileSrc.match(new RegExp("(image|movie)" + "[0-9]+."))[0].match(/[0-9]+/g)[0]) - 1;
              displayedFileType = displayedFileSrc.match(new RegExp("(image|movie)" + "[0-9]+."))[0].match(/image|movie/g)[0];
              //display the next one;
              clickedFileSrc = imgNodes.eq(clickedFileId).attr('src');
              clickedFileType = clickedFileSrc.match(new RegExp("(image|movie)" + "[0-9]+."))[0].match(/image|movie/g)[0];


              if(displayedFileType == "movie" && clickedFileType == "movie"){
                       //clickedFileSrc movie0001.mp4.png, while displaySrc is movie: movie0001.mp4
                       displayedFileNode.attr('src', clickedFileSrc.substring(0, clickedFileSrc.length - 4));
                       divFileMenu.find("img[src='"+ displayedFileSrc +".png']").css('border','none');
                       divFileMenu.find("img[src='"+ clickedFileSrc + "']").css('border','solid blue 2px');
              }
              else if(displayedFileType == "image" && clickedFileType == "image"){
                  displayedFileNode.attr('src', clickedFileSrc);
                  divFileMenu.find("img[src='"+ displayedFileSrc +"']").css('border','none');
                  divFileMenu.find("img[src='"+ clickedFileSrc +"']").css('border','solid blue 2px');
              }
              else if(displayedFileType == "movie" && clickedFileType == "image"){
                  displayedFileNode.siblings().eq(0).attr('src', clickedFileSrc);
                  displayedFileNode.siblings().eq(0).css('display','block');
                  displayedFileNode.css('display','none');
                  divFileMenu.find("img[src='"+ clickedFileSrc + "']").css('border','solid blue 2px');
                  divFileMenu.find("img[src='"+ displayedFileSrc + ".png']").css('border','none');
              }
              else if(displayedFileType == "image" && clickedFileType == "movie")
              {
                  displayedFileNode.siblings().eq(0).attr('src', clickedFileSrc.substring(0, clickedFileSrc.length - 4));
                  displayedFileNode.siblings().eq(0).css('display','block');
                  displayedFileNode.css('display','none');
                  divFileMenu.find("img[src='"+ clickedFileSrc + "']").css('border','solid blue 2px');
                  divFileMenu.find("img[src='"+ displayedFileSrc + "']").css('border','none');
              }
          }


          //move to previous movie/image
          $("div[class='file-menu-move-left']").click(function(event){
              var projectFileNode = $(this).parent();
          	  var projectName = projectFileNode.attr("id");
          	  var uploader = $(this).attr("id");
          	  var divFileMenu =  projectFileNode.children("div[class=file-menu]");
          	  var displayedFileNodes = projectFileNode.find("[class=project-file]");
              var displayedFileNode;
              var displayedFileSrc;
              for(var i = 0; i < displayedFileNodes.length ; i++){
                  if(displayedFileNodes.eq(i).css('display') != "none"){
                     displayedFileNode = displayedFileNodes.eq(i);
                     displayedFileSrc = displayedFileNode.attr('src');
                     break;
                  }
              }

          	  // display move right option
          	  divFileMenu.parent().find("[class=file-menu-move-right]").css('display' , 'block');

              var displayedFileId = parseInt(displayedFileSrc.match(new RegExp("(image|movie)" + "[0-9]+."))[0].match(/[0-9]+/g)[0]) - 1;
              var displayedFileType = displayedFileSrc.match(new RegExp("(image|movie)" + "[0-9]+."))[0].match(/image|movie/g)[0];
              var numOfMovies = divFileMenu.attr('id').match(/movie/g).length;
              displayedFileId = displayedFileType == "movie" ? displayedFileId : displayedFileId + numOfMovies;

              //switch clickedSrc and displayedSrc
              switchClickedAndDisplayed(displayedFileNode, divFileMenu, displayedFileId - 1);
              if(displayedFileId - 1 == 0 ){
                  divFileMenu.parent().find("[class=file-menu-move-left]").css('display' , 'none');
              }
          });

		  ///////////////////for ProjectText See more/////////////////////////////////////////
		  //give a hint
		  $("img[id='moretext']").mouseover(function(){
			  var projectName=$(this).parents("div[class='project']").attr("id");
			  var username=$(this).parent().children("li[class='username']").attr("id");
			  if(myWinTextMore.get(""+projectName+username)!=undefined&&myWinTextMore.get(""+projectName+username).css("display")=="none")
			  {
				  layer.tips('See more Text', $(this),{tips: [4, '#3595CC'],time: 1500});
			  }
			  else
			 {
				  layer.tips('Fold Up Text', $(this),{tips: [4, '#3595CC'],time: 1500});
			 }
		  });
		  //illustrate more text;
		  $("img[id='moretext']").click(function(){
			  var projectName=$(this).parents("div[class='project']").attr("id");
			  var username=$(this).parent().children("li[class='username']").attr("id");
			  console.log(projectName+username);
			  url='showAllText?projectName='+projectName+"&"+"uploader="+username;

			  if(myWinTextMore.get(""+projectName+username)==undefined)
			 {
				  myWinTextMore.set(""+projectName+username,$$.iframe("Project Description",$(this),{offsetx:"73.5%",offsety:$(this).offset().top-374},{src:url},{"background-color":"white","width":"24%","height":"400px"}));
				  $(this).attr('src','images/foldup-left.png');
			 }
			  else
			{
				  if(myWinTextMore.get(""+projectName+username).css("display")=="none")
				 {
					  myWinTextMore.get(""+projectName+username).fadeIn();
					  $(this).attr('src','images/foldup-left.png');
				 }
				  else
					  {
					  myWinTextMore.get(""+projectName+username).fadeOut();
					  $(this).attr('src','images/ellipse.png');
					  }
				  //myWinTextMore.css('display','none');

			}

		  });
		  /////////////////////////////////////////////////////////////////////////////////



		  //use ajax to update the thumbup information
		  $("img[id='projectthumbup']").click(function(){

				var projectName=$(this).parent().parent().parent().parent().parent().attr("id");
				var uploader=$(this).parent().parent().attr("id");
				var count=parseInt($(this).next().html().replace("(","").replace(")",""))+1;
				$(this).next().html("(" +count+")");
				$.post("thumbUp?uploader="+uploader+"&projectName="+projectName,null,
						function (data,textStatus)
						{
					      var obj=eval(data);
					      $(this).next().html("(" +(parseInt($(this).next().html().match(/\d+/)) + 1)+")");
						}
			   );
		  });
		//Download
		///use ajax to do the download option; we cannot use ajax to do submission.
		  $("img[src='images/download.png']").click(function(){
			    var uploader=$(this).parent().parent().attr("id");
			    var projectName=$(this).parent().parent().parent().parent().parent().attr("id");
			    alert("download?uploader=${user.username}&projectName="+projectName);
			    window.location.assign("download?uploader="+uploader+"&projectName="+projectName);

			    /*$.post("download?uploader=${user.username}&projectName="+projectName,null,
						function (data,textStatus)
						{
					      var obj=eval(data);
						}
			   );*/
        });
		/////Comment show or hide.
		//Dynamically update data and communicate with server;
		  $("img[id='projectcomment']").click(function(){

			  var div_project = $(this).parent().parent().parent().parent().parent();
			  var projectName =  div_project.attr("id");
			  var uploader = $(this).parent().parent().attr("id");
			  //Create html elements for comment lists;
			  if(div_project.children().last().attr("class")!="projectcomment")
			  {

				  // request comment list from servlet;
				  // use Ajax to do the job;
				 /* $.ajax({
				      url :"commentShow?uploader="+uploader+"&projectName="+projectName,
				      contentType:false,
				      method: "post",
				      dataType:"json",
				      error: function(data, textStatus, errorThrown ){
				          console.log(data + errorThrown);
				      },
				      success:function(data){
                           console.log(data + errorThrown);
				      }
				  });*/
				  $.post("commentShow?uploader="+uploader+"&projectName="+projectName,null,
							function (data,textStatus)
							{

					              ///show add comment options.
					              console.log(data);
					              var commentContent = "";
					              var commentList = JSON.parse(data);

					              var div_comment=$("<div></div>");
					              div_comment.attr("class","projectcomment");
								  //build a div to store the commentList

								  var add_comment_form = $("<form style='height:50px;'></form>");
								  var add_comment_textArea = $("<textarea value='Make a comment' style='height:50px;'>");
								  add_comment_textArea.attr("rows","2");
								  add_comment_textArea.attr("cols","97");
								  //cancel and confirm will only appear when text area has focus
								  var cancel_button = $("<input style='display:none' type='button' value='Cancel' id='cancelcomment'/>");
                                  var confirm_button = $("<input style='display:inline-block' type='button' value='POST' id='postcomment'/'>");
                                  add_comment_form.append(add_comment_textArea,$("<br>"), confirm_button);

                                  var foldUp_button = $("<img class='foldup' src='images/up.png'/>");
                                  foldUp_button.click(function()
                                  {
                                  		$(this).parent().slideUp();
                                  });
                                  //some tips when goto foldup
                                  foldUp_button.mouseenter(function()
                                  {
                                  	  layer.tips('Fold Up Comments', $(this),{tips: [4, '#3595CC'],time: 1500});
                                  });

                                  var comment_ul = $("<ul class='project-comment-list-ul'></ul>");
                                  //Show limited number of comments
                                  for (var j = 0;j < numCommentToShow;j++)
                                  {
                                  	  if(commentList[j]!=null)
                                  	 {
                                  	    var li = $("<li></li>").html("<a>" + commentList[j].commentby + "</a><span>"+commentList[j].content+"</span><div style='display:inline-block'><img class='detail-comment' src='images/ellipse.png'/></div>");
                                        comment_ul.append(li);
                                  	 }
                                  }
                                  var more_comment_div = $("<div id='morecomment'>View all "+ commentList.length +" comments</div>");
                                  if(commentList.length <= numCommentToShow)
								  {//do not show it when there is no more comments
									  more_comment_div.css("display","none");
								  }
                                  div_comment.append(add_comment_form,comment_ul, foldUp_button, more_comment_div);
								  div_project.append(div_comment);


								  cancel_button.click(function(){
									  $(this).siblings($("textarea")).val("");
									  $(this).siblings($("textarea")).blur();
									  $(this).siblings($("textarea")).attr('rows','2');
								  });

								  confirm_button.click(function()
								  {
									  //need data of
									  ////////////projectName//////////////////
									  ///////////comment content.///////////
									  //////////comment date//////////////
									  //////////username etc./////////////
									 
									 var commentContent = $(this).siblings($("textarea")).eq(0).val();
									 var d = new Date();
									 var month = d.getMonth()+1 > 10 ? d.getMonth() + 1 : "0" + d.getMonth() + 1;
									 var day = d.getDate()>10 ? d.getDate() : "0" + d.getDate();
									 var hour = d.getHours()>10 ? d.getHours() : "0" + d.getHours();
									 var minute = d.getMinutes() > 10 ? d.getMinutes():"0" + d.getMinutes();
									 var date = d.getFullYear() + "-" + month + "-" + day + " " + hour + ":" + minute;

									 //update comment list;
									 ///create a new list add it to the bottom!!
									 var li = $("<li></li>").html("<a>" + username + "</a><span>"+commentContent+"</span><div style='display:inline-block'><img class='detail-comment' src='images/ellipse.png'/></div>");
									 comment_ul.append(li);
									 //Update input form;
									 $(this).siblings($("textarea")).blur();
								     $(this).siblings($("textarea")).attr('rows','2');

								     //////////////Send comment data to server./////////////
									 $.ajax({
									    url:"commentAdd",
									    type:"post",
									    contentType:"application/json;charset=utf-8",
									    data:'{"uploader":"'+uploader+'","projectName":"'+projectName+'","content":"'+commentContent+'","date":"'+date+'","commentby":"'+username+'"}',
                                        dataType:"json",
                                        success:function(date){

                                        },
                                        error:function(data, textStatus, errorThrown){
                                           console.log(errorThrown);
                                        }
									 });
								  });

								  //see all comments
								  more_comment_div.click(function(){
								      //show all of the comments
								      //clear table
								      comment_ul.html("");
								      for(var commentIdx = 0; commentIdx < commentList.length; commentIdx++){
								          var comment = commentList[commentIdx];
								          var commentBy = comment.commentby;
								          var content = comment.content;
								          var date = comment.date;
								          var id = comment.id;
								          var level = comment.level;
								          var subComments = comment.subComments;
								          if(subComments.length == 0)
								          {
								              var li = $("<li></li>").html("<a>" + commentBy + "</a><span>" + content + "</span>"+
								              "<div style='display:inline-block'><img class='detail-comment' src='images/ellipse.png'/></div>");
								              comment_ul.append(li);
								          }
                                      }
								      
								      /*
								      //a new div generated, attach it to document. set position as absolute
								      var allCommentsDiv = $("<div class='all-comments' style='width:90%;position:fixed;background-color:white'>"+
								      "<div class='project-pic-container' style='align-items:center;display:-webkit-flex;top:50%;width:65%;height:100%;float:left;background-color:black;'></div>"+
								      "<div class='project-comment-container' style='opacity:1;width:30%;height:" + window.innerHeight +"px;float:left;background-color:white'></div>"+
                                      "</div>");
                                      var closeButton = $('<div class="close-all-comments-div" style="cursor:hand;position:absolute;top:-20px;right:-20px;">'+
                                      '<svg aria-label="Close" class="_8-yf5 " fill="white" height="30" viewBox="0 0 48 48" width="30">'+
                                      '<path clip-rule="evenodd" d="M41.8 9.8L27.5 24l14.2 14.2c.6.6.6 1.5 0 2.1l-1.4 1.4c-.6.6-1.5.6-2.1 0L24 27.5 9.8 41.8c-.6.6-1.5.6-2.1 0l-1.4-1.4c-.6-.6-.6-1.5 0-2.1L20.5 24 6.2 9.8c-.6-.6-.6-1.5 0-2.1l1.4-1.4c.6-.6 1.5-.6 2.1 0L24 20.5 38.3 6.2c.6-.6 1.5-.6 2.1 0l1.4 1.4c.6.6.6 1.6 0 2.2z" fill-rule="evenodd">'+
                                      '</path></svg></div>');
                                      allCommentsDiv.append(closeButton);
								      window.scrollY;
								      window.scrollX;
								      allCommentsDiv.css('width', window.innerWidth*0.9);
								      allCommentsDiv.css('height', window.innerHeight);

								      allCommentsDiv.css('left', 20);
                                      allCommentsDiv.css('top', 20);

                                      $("body").append(allCommentsDiv);
                                      var div_project_pic = div_project.find('div[class=project-pic]').eq(0);
                                      div_project_pic.css('width','100%');
                                      var prevs_project_pic = div_project_pic.prev();
                                      var div_project_title = div_project_pic.parent().parent().find("div[id='project-title']");
                                      div_project_pic.appendTo(allCommentsDiv.find('[class=project-pic-container]').eq(0));
                                      var new_comment_table = table.clone();
                                      new_comment_table.appendTo(allCommentsDiv.find('[class=project-comment-container]').eq(0));
                                      $("body").find("div").eq(2).css("opacity","0.3");//project main container.
                                      div_project_title = div_project_pic.parent().parent().find("div[id='project-title']");
                                      div_project_title.clone().prependTo(allCommentsDiv.find('[class=project-comment-container]').eq(0));

                                      $("div[class='close-all-comments-div']").click(function(){
                                          $("body").find("div").eq(2).css("opacity","1");//project main container.
                                          allCommentsDiv.css('display','none');
                                          div_project_pic.insertAfter(prevs_project_pic.eq(prevs_project_pic.length - 1));
                                      })
                                      */


								  });


						     }
				   );
			  }
			  else
			  {
				  //After commentList is generated we need to fade in or out. no need to communicate with server
				  ///again to get comment list;//////////
				  div_project.children().last().fadeToggle();
			  }

      });


});
