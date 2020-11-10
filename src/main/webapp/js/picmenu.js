 function displayPicMenu(projectpicNode){
              var projectname=projectpicNode.parent().parent().attr("id");
			  var uploader=projectpicNode.attr("id");
			  var divpicmenu=projectpicNode.parent().parent().children("div[id='picmenu']");
			  var currentimgsrc=projectpicNode.attr('src');
			  var curimgid=0;
			  var imgobj;

			  //display image menu
			  projectpicNode.post("getProjectImageNames",
			    		{
			    	       uploader:uploader,
			    	       projectname:projectname
			    		},
			    		function(data,textStatus)
			    		{

			    			imgobj=data;
			    			if(divpicmenu.children("img").attr('src')==undefined)
			    			{
			    				var imgmenu=$("<img>");
			    				imgmenu.attr('id',projectname);
			    				imgmenu.attr('src',"images/rightarrow2.jpg");
			    				imgmenu.css('width','9%');
			    				imgmenu.css('float','right');

			    				divpicmenu.prepend(imgmenu);
			    				var jend; var jstart=0;
			    				if(imgobj.fileNames.length>imgTotmax)
			    					jend=imgTotmax-1;
			    				else
			    					jend=imgobj.fileNames.length-1;

			    				for(var j=jend;j>=0;j--)
				    			{
				    				var picname=imgobj.fileNames[j];
				    				var imgmenu=$("<img id='projectpic'>");//imgmenu.attr('id',projectname);
				    				imgmenu.attr('src',"resource/userdata/"+uploader+"/"+projectname+"/pic/"+picname);
				    				//imgmenu.css('height','30px');
			    				    imgmenu.css('width','9%');
				    				imgmenu.css('opacity','0.6')
				    				imgmenu.css('float','left');
				    				if(currentimgsrc=="resource/userdata/"+uploader+"/"+projectname+"/pic/"+picname)
				    				{
				    					imgmenu.css('border','solid blue 2px');
				    					curimgid=j;
				    				}
				    				divpicmenu.prepend(imgmenu);


				    			}
			    				imgmenu=$("<img>");imgmenu.attr('id',projectname);
			    				imgmenu.attr('src',"images/leftarrow2.jpg");
			    				imgmenu.css('width','9%');
			    				imgmenu.css('float','left');
			    				divpicmenu.prepend(imgmenu);
				    			divpicmenu.css('display','block');
			    			}
			    			else
			    			{
			    				divpicmenu.css('display','block');
			    			}

			    			//define callback functions after this bar is created...move to next image
			    			$("img[src='images/rightarrow2.jpg']").click(function(){
			    				if(jstart>0){
			    					for(var j=jstart; j<=jend;j++){
			    						  var picname=imgobj.fileNames[j];
			    						  var picnameNew=imgobj.fileNames[j-1];
			    						  var fullsrc="resource/userdata/"+uploader+"/"+projectname+"/pic/"+picname;
			    						  var fullsrcNew="resource/userdata/"+uploader+"/"+projectname+"/pic/"+picnameNew;
			    						  $(this).parent().children("img[src='" + fullsrc + "']").attr('src',fullsrcNew);

			    					}
			    					var picname=imgobj.fileNames[curimgid-1];
			    					var fullsrc="resource/userdata/"+uploader+"/"+projectname+"/pic/"+picname;
			    					$(this).parent().next().children("img[class='projectpic']").attr('src',fullsrc);
			    					curimgid=curimgid-1;
			    					jstart=jstart-1;
			    					jend=jend-1;
			    				}
		    				 });

			    			//define callback functions after this bar is created...move to previous image
			    			$("img[src='images/leftarrow2.jpg']").click(function(){
		    					  //var projectname=$(this).attr("id");
			    				if(jend<imgobj.fileNames.length-1){
			    					for(var j=jend; j>=jstart;j--){
			    						  var picname=imgobj.fileNames[j];
			    						  var picnameNew=imgobj.fileNames[j+1];
			    						  var fullsrc="resource/userdata/"+uploader+"/"+projectname+"/pic/"+picname;
			    						  var fullsrcNew="resource/userdata/"+uploader+"/"+projectname+"/pic/"+picnameNew;
			    						  $(this).parent().children("img[src='" + fullsrc + "']").attr('src',fullsrcNew);

			    					}
			    					var picname=imgobj.fileNames[curimgid+1];
			    					var fullsrc="resource/userdata/"+uploader+"/"+projectname+"/pic/"+picname;
			    					$(this).parent().next().children("img[class='projectpic']").attr('src',fullsrc);
			    					curimgid=curimgid+1;

			    					jend=jend+1;
			    					jstart=jstart+1;


			    				}
		    				 });

			    		    //if we click on the projectpic, directly go to this one..
			    		    divpicmenu.children("img[id='projectpic']").click(function(){
			    		    	var srccur=$(this).attr('src');
			    		    	var targetimgid =0;
			    		    	targetimgid = srccur.match(/[0-9]+.png/);
			    		    	targetimgid = parseInt(targetimgid.toString().replace('.png',''))-1;
			    		    	//alert(parseInt(targetimgid));
			    		    	if(curimgid!=targetimgid){
			    		    		var picnamepre=imgobj.fileNames[curimgid];
		    						var picname=imgobj.fileNames[targetimgid];
		    						curimgid=targetimgid;
				    		    	var fullsrc="resource/userdata/"+uploader+"/"+projectname+"/pic/"+picname;
		    						$(this).parent().children("img[src='" + fullsrc + "']").css('border','solid blue 2px');
		    						var fullsrcpre="resource/userdata/"+uploader+"/"+projectname+"/pic/"+picnamepre;
		    						$(this).parent().children("img[src='" + fullsrcpre + "']").css('border','none');
		    						$(this).parent().next().children("img[class='projectpic']").attr('src',fullsrc);
			    		    	}


			    		    });


			    		});
			  divpicmenu.css('position','absolute');
  			  divpicmenu.css('top',projectpicNode.css('top'));
  			  divpicmenu.css('width','80%');

}(jQuery);