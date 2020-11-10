package com.lcs.dao;

import com.lcs.domain.User;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import org.springframework.stereotype.Repository;

@Repository
public interface UserDao {
    @Select("select * from user where username = #{username}")
    public User findUser(String username);

    @Insert("insert into user (username, password, gender, email, phone, address, remarks) values " +
            "(#{username}, #{password}, #{gender}, #{email}, #{phone}, #{address}, #{remarks})")
    public void addUser(User usr);

    @Delete("delete from user where username = #{username}")
    public void deleteUser(String username);

    //update user info neglecting null values
    @Update("<script>"+
            "UPDATE user " +
            "SET " +
            "username = #{username} "+
            "<if test = 'password != null'>" + ",password = #{password} " +"</if>"+
            "<if test = 'gender != null'>" + ",gender = #{gender} " +"</if>"+
            "<if test = 'email != null'>" + ",email = #{email} " +"</if>"+
            "<if test = 'phone != null'>" + ",phone = #{phone} " +"</if>"+
            "<if test = 'address != null'>" + ",address = #{address} " +"</if>"+
            "<if test = 'remarks != null'>" + ",remarks = #{remarks}" +"</if>"+
            " WHERE username = #{username}"+
            "</script>"
    )
    public void updateUser(User usr);
}
