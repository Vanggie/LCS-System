package com.lcs.service;

import com.lcs.dao.UserDao;
import com.lcs.domain.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;

@Service
public class UserService {
    @Autowired
    private UserDao userdao;

    public User loginService(String username, String password){
        System.out.println("Calling loginService: username: " + username +" password = " + password);
        User user = null;
        try {
            user = userdao.findUser(username);
            System.out.println("User Login: user found is " + user);
            return user;
        }
        catch (Exception e){
            e.printStackTrace();
            throw e;
        }
    }
    public void updateUser(User user){
        userdao.updateUser(user);
    }

    public boolean updateFacePhoto(String username, String contextPath, MultipartFile multipartFile) throws IOException {
        String filename = "face.jpg";
        String path = contextPath + "resource\\userdata\\" + username +"\\";
        File file = new File(path);
        if(!file.exists()){
            //user not exist
            return false;
        }
        try {
            multipartFile.transferTo(new File(path, filename));
            System.out.println("Update face photo succeed");
            return true;
        }
        catch(Exception e){
            System.out.println("Update face photo failed");
            e.printStackTrace();
            throw e;
        }
    }
}
