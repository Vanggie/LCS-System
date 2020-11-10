package com.lcs.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.lcs.domain.Project;
import com.lcs.domain.User;
import com.lcs.service.ProjectService;
import com.lcs.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@SessionAttributes({"user", "projectMap", "projectMapJson", "firstProjectTextMap", "numOfPages", "curPageNum", "startPageNum"})
public class UserController {
    @Autowired
    private UserService userService;
    @Autowired
    private ProjectService projectService;

    @RequestMapping(path="/index.html")
    public String login(HttpServletRequest request, String username, String password, Model model) throws JsonProcessingException {
        System.out.println("Session attribute: " + request.getSession().getAttribute("user"));
        User user = (User) request.getSession().getAttribute("user");
        if(user != null){
            userService.updateUser(user);
            return "homepage";
        }

        user = userService.loginService(username, password);
        if(user == null){
            model.addAttribute("message", "Username not found");
            return "forward:index.jsp";
        }
        else if (!user.getPassword().equals(password)){
            model.addAttribute("message", "Password incorrect");
            return "forward:index.jsp";
        }
        else{
            Integer numItemsOnOnePage = Integer.parseInt(request.getServletContext().getInitParameter("NumItemsOnOnePage"));
            Map<String, Project> projectMap = projectService.getProjectMap(numItemsOnOnePage, 0);
            user.setProjectList(projectService.getProjectNameListByUploader(username));
            Integer numProjectTot = projectService.getProjectCount();
            Integer numOfPages = (int)Math.ceil((double)numProjectTot/(double)numItemsOnOnePage);
            System.out.println("Num of Pages: " + numOfPages + ", Total number of Projects: " + numProjectTot);

            //projectMap
            System.out.println(projectMap);

            //get first text description
            String contextPath = request.getRealPath("/");
            Map<String, String> firstProjectTextMap = projectService.getFirstProjectTextDescription(projectMap, contextPath);
            if(projectMap == null){
                model.addAttribute("message", "Web service error, project list initilization failed. Please try again.");
                return "error";
            }
            ObjectMapper objectMapper = new ObjectMapper();
            String projectMapJson = objectMapper.writeValueAsString(projectMap);
            model.addAttribute("username", username);
            model.addAttribute("password", password);
            model.addAttribute("user", user);
            model.addAttribute("projectMap", projectMap);
            model.addAttribute("projectMapJson", projectMapJson);
            model.addAttribute("firstProjectTextMap", firstProjectTextMap);
            model.addAttribute("numOfPages", numOfPages);
            model.addAttribute("curPageNum", 1);
            model.addAttribute("startPageNum", 1);
            return "homepage";
        }
    }
    @RequestMapping(path="/viewPersonal")
    public String viewPersonal(){
        return "personal";
    }
    @RequestMapping(path="/viewSettings")
    public String viewSettings(@RequestParam("mode") String mode){
        switch(mode){
            case "face":
                return "setting-face-photo";
            case"credentials":
                return "setting-credentials";
            case"password":
                return "setting-password";
            default:
                return "error";
        }
    }

    @RequestMapping(path="/editProfile")
    public @ResponseBody Map<String, String> editProfile(HttpServletRequest request, @RequestBody User user, Model model){
        System.out.println("Updating user information:" + user);
        userService.updateUser(user);
        Map<String, String> messageMap = new HashMap<String, String>();
        messageMap.put("message", "success");
        model.addAttribute("user", user);
        return messageMap;
    }

    @RequestMapping(path="/uploadFacePhoto")
    public @ResponseBody Map<String, String> uploadFacePhoto(HttpServletRequest request, @RequestParam("blob") MultipartFile multipartFile) throws IOException {
        String filename = multipartFile.getOriginalFilename();
        System.out.println("Updating user face photo: " + filename);

        Map<String, String> messageMap = new HashMap<String, String>();
        String contextPath = request.getRealPath("/");
        User user = (User) request.getSession().getAttribute("user");
        if(user!=null) {
            String username = user.getUsername();
            if(userService.updateFacePhoto(username, contextPath, multipartFile)){
                messageMap.put("message", "success");
                messageMap.put("fullfilename", contextPath + "resource\\userdata\\" + username +"\\face.jpg");
            }
            else{
                messageMap.put("message", "failed");
            }
        }
        else{
            messageMap.put("message", "failed");
        }
        return messageMap;
    }
}
