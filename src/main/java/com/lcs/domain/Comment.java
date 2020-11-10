package com.lcs.domain;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

public class Comment implements Serializable {
    private String commentby;
    private int id;
    private int level;
    private Date date;
    private String content;
    private List<Comment> subComments = null;
    private SimpleDateFormat df=new SimpleDateFormat("yyyy-MM-dd hh:mm");
	public String getCommentby() {
		return commentby;
	}
	public void setCommentby(String commentby) {
		this.commentby = commentby;
	}
	public Date getDate() {
		return date;
	}
	public void setDate(Date date) {
		this.date = date;
	}
	public String getContent() {
		return content;
	}
	public void setContent(String content) {
		this.content = content;
	}

	public Comment() {

	}
	public Comment(String commentby, int id, int level, Date date, String content, List<Comment> subComments) {
		this.commentby = commentby;
		this.id = id;
		this.level = level;
		this.date = date;
		this.content = content;
		this.subComments = subComments;
	}

	@Override
	public String toString() {
		return "Comment{" +
				"commentby='" + commentby + '\'' +
				", id=" + id +
				", level=" + level +
				", date=" + date +
				", content='" + content + '\'' +
				", subComments=" + subComments +
				", df=" + df +
				'}';
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public List<Comment> getSubComments() {
		return subComments;
	}

	public void setSubComments(List<Comment> subComments) {
		this.subComments = subComments;
	}

	public String parseAsJson()
    {
    	
    	String cmjson="{\"commentby\":\"" + commentby
				+"\",\"id\":\"" + id
				+"\",\"id\":\"" + level
				+"\",\"date\":\"" + df.format(date)
			    +"\",\"content\":\"" + content.replace("\n","")
			    +"\",\"subComments\":[";
		for(int i = 0; subComments != null && i < subComments.size(); i++){
			String subCmjson = subComments.get(i).parseAsJson();
			cmjson = cmjson + subCmjson;
			if(i != subComments.size() - 1){
				cmjson = cmjson +",";
			}
		}

		cmjson = cmjson	+ "]}";
		return cmjson;
    }
    
}
