//see if advanced support is allowed.
var isAdvancedUpload = function() {
  var div = document.createElement('div');
  return (('draggable' in div) || ('ondragstart' in div && 'ondrop' in div)) && 'FormData' in window && 'FileReader' in window;
}();
$(document).ready(function(){
    if (isAdvancedUpload) {
      // ...advanced file upload supported
      var $box = $('#saya_avatar_box');
      $box.bind('click', selectFile);
      var $form = $("#uploadfaceimage");
      $box.addClass('has-advanced-upload');
      $('.can-drag-and-drop').css('display','inline');
      droppedFiles = false;
      $box.on('drag dragstart dragend dragover dragenter dragleave drop', function(e) {
        e.preventDefault();
        e.stopPropagation();
      })
      .on('dragover dragenter', function() {
          $box.addClass('is-dragover');
       })
      .on('dragleave dragend drop', function() {
          $box.removeClass('is-dragover');
      })
      .on('drop', function(e) {
          droppedFiles = e.originalEvent.dataTransfer.files;
          //show image on canvas
          imageSelectAndShowOnCanvas();
      });

      $("input[id='avatarfile']").on('change', function(e) { // when drag & drop is NOT supported
         //show image on canvas
          imageSelectAndShowOnCanvas();
      });
    }
    dragFunc('mark');
    zoomControl();
    dragCanvas();
    $('.uploadavatarbtn').click(function(event){
         //upload canvas 3
         $canvas3 = $("#canvas3");
         var formData = new FormData();

         var blob = canvasToBlob($canvas3[0], file.type);
         formData.append("blob", blob);
         formData.append("blobName", file.name);
         formData.append("blobType", file.type);
         $.ajax({
                     url: 'uploadFacePhoto',
                     type: 'post',
                     data: formData,
                     dataType: 'json',
                     cache: false,
                     contentType: false,
                     processData: false,
                     complete: function() {
                      // $form.removeClass('is-uploading');
                     },
                     success: function(data) {
                       if(data.message!="success"){
                           $(".uploading").css('diaplay','none');
                           $(".beforeselector").prepend("<strong>Failed uploading file...</strong>");
                       }
                       else{
                           src = $("#current-face-photo img").attr('src');
                           tmpList = src.split('?');
                           src = tmpList[0] + "?t=" + Math.random();
                           $("#current-face-photo img").attr('src', src);
                       }
                     },
                     error: function() {
                       // Log the error, show an alert, whatever works for you
                     }
         });

    });
});


function selectFile(){
        droppedFiles = false;
        $("input[id='avatarfile']").click();
}
function imageSelectAndShowOnCanvas()
{
    var $form = $("#uploadfaceimage");
    if ($form.hasClass('is-uploading')) return false;
    // $form.addClass('is-uploading').removeClass('is-error');
    if (droppedFiles) {
          file = droppedFiles;
    }
    else
    {
          file = $("input[type=file]")[0].files[0];
    }
    //update UIs
    $('#saya_avatar_box').unbind('click');
    $(".reupload").click(function(){
           $(".saya_avatar_box").bind('click', selectFile);
    });
    $(".uploading").css('diaplay','none');
    var $canvas1 = $("#select-file-canvas");
    context1 = $canvas1[0].getContext('2d');
    context3 = $("#canvas3")[0].getContext('2d');


    $(".beforeselector").css('display','none');
    $(".uploadavatarbtn").css('display','inline');
    $(".mark").css('display','inline');
    $(".zoomBar").css('display','inline');
    $(".saya_canvas3").css('display','inline');
    $(".reupload").css('display','inline');
    //read file as Image

    var reader = new FileReader();
    reader.onloadend = function(event){
          img.onload = function(ev){
                 detectAndPlotCanvas1($canvas1);
                 detectAndPlotCanvas3();
          }
          img.src = event.target.result;
    }
    reader.readAsDataURL(file);
}

//Drag and show part of the image
var canvas3SrcX = 0;
var canvas3SrcY = 0;
var canvas3SrcWidth = 10;
var canvas3SrcHeight = 10;
var img;
var context1;
var context3;
var canvas2 = document.createElement("canvas");
context2 = canvas2.getContext('2d');
var img3 = new Image();
var img = new Image();
var zoom = 1;
var canvas1SrcX = 0;
var canvas1SrcY = 0;
var canvas1SrcWidth = 10;
var canvas1SrcHeight = 10;
var droppedFiles;
var file;
function detectAndPlotCanvas1($canvas1)
{
   if($canvas1 == null)$canvas1 = $("#select-file-canvas");
   canvas1SrcWidth = zoom*img.width;
   var canvas1Width = $canvas1.attr('width');
   var canvas1Height = $canvas1.attr('height');
   canvas1SrcHeight = canvas1SrcWidth/(canvas1Width*1.0)*canvas1Height;
   context1.clearRect(0, 0, $canvas1[0].offsetWidth, $canvas1[0].offsetHeight);
   context1.drawImage(img, canvas1SrcX, canvas1SrcY, canvas1SrcWidth , canvas1SrcHeight);
}

function detectAndPlotCanvas3(){
    var $markNode = $("#mark");
    canvas3SrcWidth = $markNode[0].offsetWidth;
    canvas3SrcHeight = $markNode[0].offsetHeight;
    canvas3SrcX = $markNode[0].offsetLeft
    canvas3SrcY = $markNode[0].offsetTop;
    $canvas3 = $("#canvas3");
    dataImg = context1.getImageData(canvas3SrcX,canvas3SrcY,canvas3SrcWidth,canvas3SrcHeight);
    canvas2.width = canvas3SrcWidth;
    canvas2.height = canvas3SrcHeight;
    context2.putImageData(dataImg,0,0,0,0,canvas3SrcWidth,canvas3SrcHeight);
    var img2 = canvas2.toDataURL("image/png");
    img3.src = img2;
    context3.clearRect(0, 0, $canvas3[0].offsetWidth, $canvas3[0].offsetHeight);
    img3.onload  = function(){
          context3.drawImage(img3,0,0,$canvas3[0].offsetWidth, $canvas3[0].offsetHeight)
    }
}
function canvasToBlob(canvas, type){
    var byteString = atob(canvas.toDataURL().split(",")[1]),
           ab = new ArrayBuffer(byteString.length),
           ia = new Uint8Array(ab),
           i;

    for (i = 0; i < byteString.length; i++) {
          ia[i] = byteString.charCodeAt(i);
    }

    return new Blob([ab], {
           type: type
    });
}
function dragFunc(id){
    var dragNode = document.getElementById(id);
    dragNode.onmousedown = function(event)
    {
         var ev = event || window.event;
         event.stopPropagation();
         var disX = ev.clientX;
         var disY = ev.clientY;
         var isInRoundControl = false;
         var markSize = dragNode.offsetWidth;
         if(ev.target.className == 'rdcontrol') isInRoundControl = true;
         document.onmousemove = function(event) {
             var ev = event || window.event;
             var canvas1 = document.getElementById('select-file-canvas');
             var dx = ev.clientX - disX;
             var dy = ev.clientY - disY;

             if(isInRoundControl){
                 minD = Math.min(dx, dy);
                 var newMarkSize = markSize + minD;
                 if(newMarkSize < 0)newMarkSize = 20;
                 if(dragNode.offsetLeft + newMarkSize > canvas1.offsetLeft + canvas1.offsetWidth)newMarkSize = canvas1.offsetLeft + canvas1.offsetWidth - dragNode.offsetLeft ;
                 if(dragNode.offsetTop + newMarkSize > canvas1.offsetTop + canvas1.offsetHeight)newMarkSize = canvas1.offsetTop + canvas1.offsetHeight - dragNode.offsetTop ;

                 dragNode.style.width = newMarkSize;
                 dragNode.style.height = newMarkSize;
                 $(".clipround").css('width', newMarkSize -2);
                 $(".clipround").css('height', newMarkSize);

                 canvas3SrcWidth = newMarkSize;
                 canvas3SrcHeight = newMarkSize;
                 detectAndPlotCanvas3();
                 return;
             }
             var newOffsetX = dragNode.offsetLeft + dx;
             var newOffsetY = dragNode.offsetTop + dy;
             if(newOffsetX + dragNode.offsetWidth > canvas1.offsetLeft + canvas1.offsetWidth) newOffsetX = canvas1.offsetLeft + canvas1.offsetWidth - dragNode.offsetWidth;
             if(newOffsetY + dragNode.offsetHeight > canvas1.offsetTop + canvas1.offsetHeight) newOffsetY = canvas1.offsetTop + canvas1.offsetHeight - dragNode.offsetHeight;
             if(newOffsetX < canvas1.offsetLeft) newOffsetX = canvas1.offsetLeft;
             if(newOffsetY < canvas1.offsetTop) newOffsetY = canvas1.offsetTop;
             dragNode.style.left = newOffsetX;
             dragNode.style.top = newOffsetY;
             disX = ev.clientX;
             disY = ev.clientY;
             canvas3SrcX = newOffsetX;
             canvas3SrcY = newOffsetY;
             detectAndPlotCanvas3();
         };
         dragNode.onmouseup = function() {
             document.onmousemove = null;
         };
    };
}

function zoomControl()
{
     var zoomCtrNode = document.getElementById('zoomControl');
     var zoomBarNode = document.getElementById('zoomControlBar');
     zoomCtrNode.onmousedown = function(event){
         var ev = event || window.event;
         event.stopPropagation();
         var zoomBarLength = zoomBarNode.offsetWidth;
         var disX = ev.clientX;
         var zoomCtrX = zoomCtrNode.offsetLeft;
         document.onmousemove = function(event) {
             var ev = event || window.event;
             var dx = ev.clientX - disX;
             newZoomCtrX = zoomCtrX + dx;
             if(newZoomCtrX < -8)newZoomCtrX = -8;
             if(newZoomCtrX > zoomBarLength - 12)newZoomCtrX = zoomBarLength - 12;
             //minimum zoom = 0.1;
             var newZoom = 1 - (newZoomCtrX + 8 )/(zoomBarLength -4)*(1 - 0.1);
             zoomCtrNode.style.left = newZoomCtrX;
             zoom = newZoom;
             detectAndPlotCanvas1(null);
             detectAndPlotCanvas3();
         }
         zoomCtrNode.onmouseup = function() {
                      document.onmousemove = null;
         };

     };
}

function dragCanvas(){
    var $canvas1 = $('#select-file-canvas');
    $canvas1[0].onmousedown = function(event){
        var ev = event || window.event;
        event.stopPropagation();
        var disX = ev.clientX;
        var disY = ev.clientY;
        document.onmousemove = function(event) {
            var ev = event || window.event;
            var dx = ev.clientX - disX;
            var dy = ev.clientY - disY;
            canvas1SrcX = canvas1SrcX + dx;
            canvas1SrcY = canvas1SrcY + dy;
            disX = disX + dx;
            disY = disY + dy;

            if(canvas1SrcX > 0) canvas1SrcX = 0;
            if(-canvas1SrcX + $canvas1[0].offsetWidth > img.width)canvas1SrcX = $canvas1[0].offsetWidth - img.width;
            if(canvas1SrcY > 0) canvas1SrcY = 0;
            if(-canvas1SrcY + $canvas1[0].offsetHeight> img.height)canvas1SrcY = $canvas1[0].offsetHeight -img.height;
            detectAndPlotCanvas1(null);
            detectAndPlotCanvas3();
        }
        document.onmouseup = function() {
              document.onmousemove = null;
        };
    }
}








