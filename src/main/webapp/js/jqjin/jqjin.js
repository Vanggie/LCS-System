/**
 * Do widow pop out. based on jquery;
 */
//load css files;///////////////////////////////////////////////
var scripts = $("script")
var script = null;
    var len = scripts.length;
    
    for(var i = 0; i < scripts.length; i++) {
    	if(scripts[i].src.indexOf("jqjin.js") != -1) {
            script = scripts[i];
            break;
        }
    }
   // alert(script.src.replace("jqjin.js","css/jqjin.css"));
var csslink=$("<link type='text/css' rel='stylesheet'/>");
csslink.attr("href",script.src.replace("jqjin.js","css/jqjin.css"));
//csslink.attr("href","css/jqjin.css");
$("head").append(csslink);
////////////////////////////////////////////////////////////////

/////////////define a function can be called by all jquery objects.
$.fn.showAwhile = function(timeout){
    this.each(function(){
        $(this).fadeIn(500);
        setTimeout("",timeout);
        $(this).fadeOut(500);
    });    
};
$.fn.suicide = function(){
    this.each(function(){
        $(this).remove();
    });    
};
/////////////////jquery function expand//////////////////////////////
(function ($) {
    $$ = function (element) {return $(element)};
    $.extend
    ($$,  //Message Box
    {    msg: function(title,attachToobj,param)
         {
    	   title=(typeof title=="string")?title:"Message";
    	   title=(title.trim()=="")?"Message":title;
    	   var obj=$("<div class=\"window-message\">" +
            		"<div class=\"title\"\"><span>" +
            		title +
            		"</span><span id='close'>X</span></div>" +
            		"<div class=\"content\">" +param.content+
            		"</div></div>");
            $("body").append(obj);
           // console.log(param.titlebgcolor);
            obj.find("span[id='close']").click(function(){obj.fadeOut();obj.suicide();})
            var width=title.length*26+26;width=(width>200)?width:200;width=(width>700)?700:width;
            obj.css("width",width+"px");
            //obj.fadeIn(500).delay(param.timeout-1000).fadeOut(500);
            try
            {
            	if(attachToobj instanceof Object)
            	{
                  obj.css("left",attachToobj.offset().left+attachToobj.outerWidth()+3);
                  obj.css("top",attachToobj.offset().top);
                  if(param.attachposition!=undefined)
                  {
               	   if(param.attachposition=="0")
               	   {
               		   obj.css("left",attachToobj.offset().left+attachToobj.outerWidth());
                          obj.css("bottom",attachToobj.offset().top);
               	   }
               	   if(param.attachposition=="1")
               	   {
               		   obj.css("left",attachToobj.offset().left+attachToobj.outerWidth());
                          obj.css("top",attachToobj.offset().top);
               	   }
               	   if(param.attachposition=="2")
               	   {
               		   obj.css("left",attachToobj.offset().left);
                          obj.css("top",attachToobj.offset().top+attachToobj.outerHeight());
               	   }
               	   if(param.attachposition=="3")
               	   {
               		   obj.css("right",attachToobj.offset().left);
                          obj.css("top",attachToobj.offset().top);
               	   }
                  }
                 
            	}
            	if(param.timeout==null)
            	{
            		obj.fadeIn(500); 
            	}
            	else
            	{
                  //  obj.fadeIn(500).delay(param.timeout-1000).fadeOut(500);
            	}
            	if(param.titlebgcolor!=undefined)
                {  
                  obj.children().eq(0).css("background-color",param.titlebgcolor);alert("0");
                }
                if(param.contentbgcolor!=undefined)
                { 
                  obj.children().eq(1).css("background-color",param.contentbgcolor);alert("1");
                }
            }
            catch(e)
            {
            	console.log("error exception!");
            }
            finally
            {
            return obj;
            }
         },
         //Showing tips.
         //do we need to destroy these messages?????????
         tips: function(title,attachToobj,param)
         {
            var obj=$("<div class='window-tips'><div class='window-tips-arrow'></div><div class='window-tips-content'>" +
            		param.content+
            		"</div></div>");
            $("body").append(obj);
            
            try{
            	if(attachToobj instanceof Object)
            	{
            	   obj.css("left",attachToobj.offset().left+attachToobj.outerWidth());
                   obj.css("top",attachToobj.offset().top);
                   if(param.attachposition!=undefined)
                   {
                	   if(param.attachposition=="0")
                	   {
                		   obj.css("left",attachToobj.offset().left+attachToobj.outerWidth());
                           obj.css("bottom",attachToobj.offset().top);
                	   }
                	   if(param.attachposition=="1")
                	   {
                		   obj.css("left",attachToobj.offset().left+attachToobj.outerWidth());
                           obj.css("top",attachToobj.offset().top);
                	   }
                	   if(param.attachposition=="2")
                	   {
                		   obj.css("left",attachToobj.offset().left);
                           obj.css("top",attachToobj.offset().top+attachToobj.outerHeight());
                	   }
                	   if(param.attachposition=="3")
                	   {
                		   obj.css("right",attachToobj.offset().left);
                           obj.css("top",attachToobj.offset().top);
                	   }
                   }
            	}
            	obj.fadeIn(500).delay(param.timeout-1000).fadeOut(500);
                var height=(50>attachToobj.height())?attachToobj.height():50;
                var width=height;
                obj.css("height",height+"px");
                obj.find("div[class='window-tips-content']").css("height",height+"px");
                height=height/2;
                width=width/2;
                obj.find("div[class='window-tips-arrow']").css("border-right-width",width+"px");
                obj.find("div[class='window-tips-arrow']").css("border-left-width",width+"px");
                obj.find("div[class='window-tips-arrow']").css("border-top-width",height+"px");
                obj.find("div[class='window-tips-arrow']").css("border-bottom-width",height/3+"px");
                
                if(param.bgcolor!=undefined)
                {
                	obj.find("div[class='window-tips-content']").css("background-color",param.bgcolor);
                	obj.find("div[class='window-tips-arrow']").css("border-right-color",param.bgcolor);
                }
            }
            finally
            {
                return obj;
            }
         },
         
         iframe: function(uuid,attachToobj,param,attr,cssstyle)
         {
        	 var obj=$("<iframe class='window-frame' scrolling='yes' url='error/404.jsp'></iframe>");
        	 $("body").append(obj);
        	 //attachToobj.after(obj);
        	 //$("body").css({"filter":"alpha(opacity=30)","opacity":"0.3"});
        	 var offsetx=(param.offsetx==undefined)?0:param.offsetx;
        	 var offsety=(param.offsety==undefined)?0:param.offsety;
        	 
        	obj.css("position","absolute");
        	try{
        	  obj.attr("uuid",uuid);
        	//set css style.
         	 if(cssstyle instanceof Object)
         	{
         		 for (x in cssstyle)
         		 {
         			 obj.css(x,cssstyle[x]);
         		 }
         	}
         	 
         	 //set attributes
         	 if(attr instanceof Object)
          	{
          		 for (x in attr)
          		 {
          			 obj.attr(x,attr[x]);
          			 
          		 }
          	}
         	
      	    if(attachToobj instanceof Object)
        	{
             // obj.css("left",attachToobj.offset().left+attachToobj.outerWidth()+3);
             // obj.css("top",attachToobj.offset().top);
      		   
              if(param.attachposition!=undefined)
              {
            	  //left
           	   if(param.attachposition=="0")
           	   {
           		   obj.css("left",attachToobj.offset().left-obj.innerWidth+offsetx);
                   obj.css("top",attachToobj.offset().top+attachToobj.height()-attachToobj.innerHeight()+offsety);
           	   }
           	   if(param.attachposition=="1")
           	   {
           		   obj.css("left",attachToobj.offset().left+attachToobj.outerWidth());
                      obj.css("top",attachToobj.offset().top);
           	   }
           	   if(param.attachposition=="2")
           	   {
           		   obj.css("left",attachToobj.offset().left);
                      obj.css("top",attachToobj.offset().top+attachToobj.outerHeight());
           	   }
           	   if(param.attachposition=="3")
           	   {
           		    obj.css("left",attachToobj.offset().left);
                      obj.css("top",attachToobj.offset().top);
           	   }
              }
              else
             {
          	     obj.css("left",offsetx);
                 obj.css("top",offsety);
              }
             
        	}
        	
        	}
        	catch(e)
           	{}
        	
        	
        	 
        	finally{
          		return obj;
          	}
             
        	
         }
             
             
             
             
             
  });
})(jQuery);






