package com.lcs.domain;

import java.io.Serializable;

public class Project implements Serializable {
	private String projectname;
	private String uploader;
	private String author;
	private Integer text;
	private Integer pic;
	private Integer mov;
	private String firstPicName;
	private String firstMovName;
	private String firstAttachmentName;
	private Integer attachment;
	private Integer thumbUp;
	private Integer weight;

	public Project(){
		this.projectname = null;
		this.uploader = null;
		this.author = null;
		this.text = 0;
		this.pic = 0;
		this.mov = 0;
		this.firstPicName=null;
		this.firstMovName=null;
		this.firstAttachmentName=null;
		this.attachment = 0;
		this.thumbUp = 0;
		this.weight = 0;
	}

	public Project(String projectname, String uploader, String author, Integer text, Integer pic, Integer mov, String firstPicName, String firstMovName, String firstAttachmentName, Integer attachment, Integer thumbUp, Integer weight) {
		this.projectname = projectname;
		this.uploader = uploader;
		this.author = author;
		this.text = text;
		this.pic = pic;
		this.mov = mov;
		this.firstPicName = firstPicName;
		this.firstMovName = firstMovName;
		this.firstAttachmentName = firstAttachmentName;
		this.attachment = attachment;
		this.thumbUp = thumbUp;
		this.weight = weight;
	}
	public String getFirstPicName() {
		return firstPicName;
	}

	public void setFirstPicName(String firstPicName) {
		this.firstPicName = firstPicName;
	}

	public String getFirstMovName() {
		return firstMovName;
	}

	public void setFirstMovName(String firstMovName) {
		this.firstMovName = firstMovName;
	}

	public String getFirstAttachmentName() {
		return firstAttachmentName;
	}

	public void setFirstAttachmentName(String firstAttachmentName) {
		this.firstAttachmentName = firstAttachmentName;
	}


	@Override
	public String toString() {
		return "Project{" +
				"projectname='" + projectname + '\'' +
				", uploader='" + uploader + '\'' +
				", author='" + author + '\'' +
				", text=" + text +
				", pic=" + pic +
				", mov=" + mov +
				", firstPicName='" + firstPicName + '\'' +
				", firstMovName='" + firstMovName + '\'' +
				", firstAttachmentName='" + firstAttachmentName + '\'' +
				", attachment=" + attachment +
				", thumbUp=" + thumbUp +
				", weight=" + weight +
				'}';
	}

	public String getProjectname() {
		return projectname;
	}

	public void setProjectname(String projectname) {
		this.projectname = projectname;
	}

	public String getUploader() {
		return uploader;
	}

	public void setUploader(String uploader) {
		this.uploader = uploader;
	}

	public String getAuthor() {
		return author;
	}

	public void setAuthor(String author) {
		this.author = author;
	}

	public Integer getText() {
		return text;
	}

	public void setText(Integer text) {
		this.text = text;
	}

	public Integer getPic() {
		return pic;
	}

	public void setPic(Integer pic) {
		this.pic = pic;
	}

	public Integer getMov() {
		return mov;
	}

	public void setMov(Integer mov) {
		this.mov = mov;
	}

	public Integer getAttachment() {
		return attachment;
	}

	public void setAttachment(Integer attachment) {
		this.attachment = attachment;
	}

	public Integer getThumbUp() {
		return thumbUp;
	}

	public void setThumbUp(Integer thumbUp) {
		this.thumbUp = thumbUp;
	}

	public Integer getWeight() {
		return weight;
	}

	public void setWeight(Integer weight) {
		this.weight = weight;
	}
}
