package com.lcs.domain;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

import java.io.Serializable;
import java.util.List;
import java.util.Map;



@Component
////Only when user is serializable, session won't lose it.............
public class User implements Serializable{

		private String username;
		private String password;
		private String authority;
		private String gender;
		private String email;
		private String phone;
		private String address;
		private String remarks;
		private List<String> projectList;

	public String getAuthority() {
		return authority;
	}

	public void setAuthority(String authority) {
		this.authority = authority;
	}

	@Override
	public String toString() {
		return "User{" +
				"username='" + username + '\'' +
				", password='" + password + '\'' +
				", authority='" + authority + '\'' +
				", gender='" + gender + '\'' +
				", email='" + email + '\'' +
				", phone='" + phone + '\'' +
				", address='" + address + '\'' +
				", remarks='" + remarks + '\'' +
				", projectList=" + projectList +
				'}';
	}

	public User() {

	}




	public String getGender() {
		return gender;
	}

	public void setGender(String gender) {
		this.gender = gender;
	}


	public String getPhone() {
	return phone;
}
    public void setPhone(String phone) {
	this.phone = phone;
}
    public String getAddress() {
	return address;
}
    public void setAddress(String address) {
	this.address = address;
}
    public String getUsername() {
	   return username;
   }
    public void setUsername(String username) {
	   this.username = username;
   }
    public String getRemarks() {
	  return remarks;
    }
    public void setRemarks(String remarks) {
	  this.remarks = remarks;
    }
    public void setPassword(String password)
   {
	   this.password=password;
   }
    public String getPassword()
   {
	   return this.password;
   }
	public List<String> getProjectList() {
		return projectList;
	}
	public void setProjectList(List<String> projectList) {
		this.projectList = projectList;
	}

	public void setEmail(String email)
   {
	   this.email=email;
   }
    public String getEmail()
   {
	   return this.email;
   }
    public String[] getRemarksAsArray(){
		return remarks.split(",");
	}
}
