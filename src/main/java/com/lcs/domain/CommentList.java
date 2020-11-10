package com.lcs.domain;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class CommentList implements Serializable {
    private String projectName=null;
	private String uploader=null;
	private List<Comment> comment=null;
	public String getProjectName() {
		return projectName;
	}
	public void setProjectName(String projectName) {
		this.projectName = projectName;
	}

	public String getUploader() {
		return uploader;
	}

	public void setUploader(String uploader) {
		this.uploader = uploader;
	}

	public List<Comment> getComment() {
		return comment;
	}
	public void setComment(List<Comment> comment) {
		this.comment = new ArrayList<Comment>();
		for(int i=0;comment!=null&&i<comment.size();i++)
		{
			this.comment.add(i, comment.get(i));
		}
		
	}

	@Override
	public String toString() {
		return "CommentList{" +
				"projectName='" + projectName + '\'' +
				", uploader='" + uploader + '\'' +
				", comment=" + comment +
				'}';
	}
}
