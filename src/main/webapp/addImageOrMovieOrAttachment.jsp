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
<title>Add Image to Project</title>
<script>
////////////////////////////////Global variables//////////////////////////////////////////
var fileList; //selected files
var fileType = "${param.fileType}";
var allowedFileExtensions;
var allowedFileRegExp;
var targetUrl = "addFile";
if(fileType == "image"){
    allowedFileExtensions = ".png, .jpg, .tiff, .tif, .eps, .gif";
    allowedFileRegExp = /(png|jpg|tiff|tif|eps|gif|PNG|JPG|TIFF|TIF|EPS|GIF)/g;
}
else if(fileType == "movie")
{
    allowedFileExtensions = ".mp4, .ogg";
    allowedFileRegExp = /(ogg|mp4|ogg|MP4)/g;
}
else if(fileType == "attachment"){
    allowedFileExtensions = ".pdf, .ppt(x), .doc(x), .docx, .xls";
    allowedFileRegExp = /(pdf|pptx|ppt|doc|docx|xls|PDF|PPTX|PPT|DOC|DOCX|XLS)/g;
}

//////////////////////////////////////////////////////////////////////////////////////////


$(document).ready(function(){
	$("#submit").click(function(){
		//Verify form
		var projectname=$("#projectname").val();
		var projecttext=$("#projecttext").val();
		if(projectname==null||$.trim(projectname)=="")
		{
			$('#projectname').val('Project Name Cannot Be Empty');
			$('#projectname').css('background-color', 'red');
		}
		else
	    {
	         $("#progress-wrp").css('display','block');
	         for(var i = 0; i < fileList.length; i++){
	             var file = fileList[i];
	             var upload = new Upload(file);
                 // maybe check size or type here with upload.getSize() and upload.getType()
                 // execute upload
                 upload.doUpload();
                 var percent = (i + 1 )/fileList.length*100;
                 setTimeout(function(){
                 $("#progress-wrp" + " .progress-bar").css("width", +percent + "%");
                 $("#progress-wrp" + " .status").text(percent + "%");
                 },
                 1000);
             }
             $("#message").css('display', 'block');
             $("#message").css('color', 'red');

             var count = 5;
             setInterval(closeWindow,1000);
             function closeWindow(){
                 $("#message").html("This window will be closed automatically in <strong style='font-size:20px'>"+ count +"</strong> seconds");
                 count--;
                 if($("#message strong").text() == '0')
                 {
                     //close window
                     var iframes = window.parent.document.getElementsByTagName('iframe');
                     window.parent.location.reload();
                     $(window.parent.document).find("div").css("opacity","1");
                     for( var i = 0;i < iframes.length; i++){
                         if(iframes[i].getAttribute('uuid')=='${param.uuid}')$(iframes[i]).suicide();
                     }
                 }
             }



	    }
	});
	$("#projectname").focus(function(){
	     $('#projectname').val('');
         $('#projectname').css('background-color', 'white');

	});
	$("#cancel").click(function(){
		var someIframe = window.parent.document.getElementsByTagName('iframe');
		$(window.parent.document).find("div").css("opacity","1");
		$(someIframe).css('display','none');
	});
	$("input[id=selectFile]").click(function(){
	    $("input[type=file]").click();
	});
	$("input[type=file]").on('change',function(){
	    $("#submit").attr('disabled', false);
	    var newFileList = $("input[type=file]")[0].files;
	    if(fileList == undefined){
        	 fileList = Array.from(newFileList);
             for(var i = 0; i < fileList.length; i++)
             {
                tmpList = fileList[i].name.split('.');
                if(tmpList[tmpList.length-1].match(allowedFileRegExp) == null){
                    fileList.splice(i, 1);
                    i = i - 1;
                 }
             }
             if(fileList.length == 0)
             {
                $("#submit").attr('disabled', true);
             }
        }
        else{
             var idxStart = fileList.length;
             for(var i = 0; newFileList != undefined && i < newFileList.length; i++){
                 fileList.push(newFileList[i]);
             }
        }
	    for(var i = 0; newFileList != undefined && i < newFileList.length; i++){
	       tmpList = newFileList[i].name.split('.');
	       if(tmpList[tmpList.length-1].match(allowedFileRegExp) != null){
	            newFileListNode = $("<tr><td style='width:80%;float:left;background-color:#4CAF50;'>"+newFileList[i].name+"</td><td id='" + newFileList[i].name + "' style='width:10%;float:right'><img id='deleteIcon' onclick='deleteFile(this)' src='images/delete2.png' style='cursor:hand;width:20px;float:right;'/></td></tr>");
	            $('#fileList').append(newFileListNode);
	       }
	       else{
	           newFileListNode = $("<tr><td style='width:80%;float:left;background-color:red;'>"+newFileList[i].name+"</td><td id='" + newFileList[i].name + "' style='width:10%;float:right'><img id='deleteIcon' onclick='deleteFile(this)' src='images/delete2.png' style='cursor:hand;width:20px;float:right;'/></td></tr>");
               $('#fileList').append(newFileListNode);
	       }
    	}

    	//display file List
    	$("#files-selected").css('display','block');
    	if(fileList.length != 0)
        {
               $("#submit").attr('disabled', false);
        }

    });
});
    function deleteFile(element){
       element.parentNode.parentNode.parentNode.removeChild(element.parentNode.parentNode);
       var fileName = element.parentNode.parentNode.childNodes[0].innerHTML;
       for(var i = 0; i < fileList.length; i++)
       {
           if(fileList[i].name == fileName){
               fileList.splice(i, 1);
               break;
           }
       }
       if(fileList.length == 0)
       {
           $("#submit").attr('disabled', true);
       }
    }
    var Upload = function (file) {
        this.file = file;
    };

    Upload.prototype.getType = function() {
        return this.file.type;
    };
    Upload.prototype.getSize = function() {
        return this.file.size;
    };
    Upload.prototype.getName = function() {
        return this.file.name;
    };
    Upload.prototype.doUpload = function () {
        var that = this;
        var formData = new FormData();

        // add assoc key values, this will be posts values
        formData.append("file", this.file, this.getName());
        formData.append("upload_file", true);
        formData.append("username", "${param.username}");
        formData.append("projectname", $("#projectname").val());
        formData.append("fileType", fileType);

        $('.progress-wrp').css('display:block');
        $.ajax({
            type: "POST",
            url: targetUrl,
            xhr: function () {
                var myXhr = $.ajaxSettings.xhr();
                if (myXhr.upload) {
                    //myXhr.upload.addEventListener('progress', that.progressHandling, false);
                }
                return myXhr;
            },
            success: function (data) {
                // your callback here
                if(data.message == "success"){
                    $("td[id="+this.getName()+"]").append($("<img src='images/uploadSuccess.png' style='cursor:hand;width:20px;float:right;'/>"));
                }
                else{
                    $("td[id="+this.getName()+"]").append($("<span>Failed</span> <img src='images/retry.jpg'/>"));
                    $("td[id="+this.getName()+"] a").click(function(){
                        this.doUpload();
                    });
                }
            },
            error: function (error) {
                // handle error
                $$.tips("message",null,{content:"Service error trying to add image",timeout:"3000",attachposition:"2"});
            },
            async: false,
            data: formData,
            cache: false,
            contentType: false,
            processData: false,
            timeout: 60000
        });
    };

    Upload.prototype.progressHandling = function (event) {
        var percent = 0;
        var position = event.loaded || event.position;
        var total = event.total;
        var progress_bar_id = "#progress-wrp";
        if (event.lengthComputable) {
            percent = Math.ceil(position / total * 100);
        }
        // update progressbars classes so it fits your code
        $(progress_bar_id + " .progress-bar").css("width", +percent + "%");
        $(progress_bar_id + " .status").text(percent + "%");
    };
</script>
</head>
<body>
<div id="title"></div>
<script>
    $("div[id=title]").text("Add ${param.fileType} (" + allowedFileExtensions + ") to project");
</script>
<div id="form">


<form action="javascript:void(0)" method="post" enctype="multipart/form-data">
  <div class='hd'>Project name:</div>
  <input class='content' id="projectname" list="projects" name="projectname" style="width:60%;float:right;" autocomplete="off"/>
  <datalist id="projects">
      <c:forEach var="projectName" items="${user.projectList}">
      <option value="${projectName}" style="width:40%;float:right;"/>
      </c:forEach>
  </datalist>
  <br>

  <input id="selectFile" value="select Files"/>
  <input id="cancel" type="submit" value="close" style='float:right;margin-left:5px'/>
  <input id="submit" type="submit" value="submit" disabled style='float:right'/>


  <input type="file" style="opacity:0%" name="addFileButton" value="#" multiple></input><br>
<table id = 'files-selected' style="width:100%;display:none;border:dashed gray 1px">
  <caption style='width:100%;display:table;text-align:left;'><div style='backgroumd-color:#F2F6F7'>Files selected(red one is not supported)</div></caption>
  <tbody id = "fileList" style="width:100%;display:table">
  </tbody>
</table>
<div id="progress-wrp" style='display:none'>
      <div class="progress-bar"></div>
      <div class="status">0%</div>
</div>
<div id='message' style='display:none;margin:5px auto;text-align:center;'>
</div>
</form>
</div>

</body>
</html>