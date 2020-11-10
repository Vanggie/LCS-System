/**
 * 
 */

			////functions to callback the codefoot options;
			$(document).ready(function(){
				  //use ajax to update the thrumbup information
				  $("img[src='${pageContext.servletContext.contextPath}/images/thrumbup.png']").click(function(){
						$(this).next().html("(" +(parseInt($(this).next().html().match(/\d+/)) + 1)+")");
						var codename=$(this).parent().parent().parent().attr("id");
						$.post("${pageContext.servletContext.contextPath}/thrumbup?codebelongsto=${user.username}&codename="+codename,null,
								function (data,textStatus)
								{
							   
							      var obj=eval(data);
							      //do something to change the jsp..
							      //alert(textStatus+": codename, thrumbupcount="+obj[0].thrumbup);
							      $(this).next().html("(" +obj[0].thrumbup+")");
								}
					   );			
				  });
				//thrumbdown.........
				//use ajax to update the thrumbdown information
				  $("img[src='${pageContext.servletContext.contextPath}/images/thrumbdown.png']").click(function(){
						$(this).next().html("(" +(parseInt($(this).next().html().match(/\d+/)) + 1)+")");
						var codename=$(this).parent().parent().parent().attr("id");
						$.post("${pageContext.servletContext.contextPath}/thrumbdown?codebelongsto=${user.username}&codename="+codename,null,
								function (data,textStatus)
								{
							   
							      var obj=eval(data);
							      //alert(textStatus+": codename, thrumbdowncount="+obj[0].thrumbdown);
							      $(this).next().html("(" +obj[0].thrumbdown+")");
								}
					   );
                  });	
				//Download
				//use ajax to do the download option; we cannot use ajax to do submission.
				  $("img[src='${pageContext.servletContext.contextPath}/images/download.png']").click(function(){
						var codename=$(this).parent().parent().parent().attr("id");//alert("${pageContext.servletContext.contextPath}/download?codebelongsto=${user.username}&codename="+codename);
						window.location("${pageContext.servletContext.contextPath}/download?codebelongsto=${user.username}&codename="+codename);
						/*$.post("${pageContext.servletContext.contextPath}/download?codebelongsto=${user.username}&codename="+codename,null,
								function (data,textStatus)
								{
							   
							      var obj=eval(data);
							      //alert(textStatus+": codename, thrumbdowncount="+obj[0].thrumbdown);
							      $(this).next().html("(" +obj[0].thrumbdown+")");
								}
					   );*/
                });
				/////comment
				  $("img[src='${pageContext.servletContext.contextPath}/images/comment.jpg']").click(function(){
					    var codename=$(this).parent().parent().parent().attr("id");//alert("${pageContext.servletContext.contextPath}/download?codebelongsto=${user.username}&codename="+codename);
						var div_comment=$(this).parent().parent().parent().children("codecomment");
						
						alert(div_comment.first().children("a").first().attr("href"));
						//alert(codename);
						//div_comment.first().
						//window.location("${pageContext.servletContext.contextPath}/download?codebelongsto=${user.username}&codename="+codename);
						/*$.post("${pageContext.servletContext.contextPath}/download?codebelongsto=${user.username}&codename="+codename,null,
								function (data,textStatus)
								{
							   
							      var obj=eval(data);
							      //alert(textStatus+": codename, thrumbdowncount="+obj[0].thrumbdown);
							      $(this).next().html("(" +obj[0].thrumbdown+")");
								}
					   );*/
              });
			});
			
