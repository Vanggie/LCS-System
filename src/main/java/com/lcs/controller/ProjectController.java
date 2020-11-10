package com.lcs.controller;

import com.lcs.service.ProjectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

@Controller
public class ProjectController {
    @Autowired
    private ProjectService projectService;


    @RequestMapping(path="/addText")
    public @ResponseBody Map<String, String> addText(HttpServletRequest request, @RequestBody Map<String, String> params)
    {
        String uploader = params.get("uploader");
        String projectname = params.get("projectname");
        String projecttext = params.get("projecttext");
        System.out.println("Calling ProjectController.addText: " + projectname + " "+ uploader +" "+ projecttext);
        String contextPath = request.getRealPath("/");
        boolean status = projectService.addTextToProject(projectname, uploader, projecttext, contextPath);
        Map<String, String> messageMap = new HashMap<String, String>();
        if(status){
            messageMap.put("message","success");
        }
        else{
            messageMap.put("message","failed");
        }
        return messageMap;
    }


    @RequestMapping(path="/addFile")
    public @ResponseBody Map<String, String> addFile(HttpServletRequest request, @RequestParam("file") MultipartFile multipartFile, @RequestParam("username") String username, @RequestParam("fileType") String fileType, @RequestParam("projectname") String projectname) throws Exception {
        String filename = multipartFile.getOriginalFilename();
        System.out.println("Upload file..." + filename);
        String contextPath = request.getRealPath("/");
        boolean status = projectService.addFileToProject(projectname, username, multipartFile, fileType, contextPath);
        Map<String, String> messageMap = new HashMap<String, String>();
        if(status){
            messageMap.put("message","success");
        }
        else{
            messageMap.put("message","failed");
        }
        return messageMap;
    }

    @RequestMapping(path="/getProjectFileNames")
    public @ResponseBody
    HashMap<String, ArrayList<String>> getProjectFileNames(HttpServletRequest request, @RequestBody Map<String, String> params){
        String uploader = params.get("uploader");
        String projectName = params.get("projectName");
        String fileType = params.get("fileType");
        System.out.println("Get all " + fileType + " under " + projectName);
        String contextPath = request.getRealPath("/");
        ArrayList<String> fileNames = projectService.getProjectFileNames(projectName, uploader, contextPath, fileType);
        HashMap<String, ArrayList<String>>  messageMap = new HashMap<String,ArrayList<String>>();
        messageMap.put("fileNames", fileNames);
        return messageMap;
    }
    @RequestMapping(path="/showAllText")
    public void showAllText(HttpServletRequest request, HttpServletResponse response, String uploader, String projectname) throws IOException {
        String contextPath = request.getRealPath("/");
        ArrayList<String> textArray= projectService.getAllTextDescription(projectname, uploader, contextPath);
        PrintWriter wr=response.getWriter();
        response.setContentType("text/html");
        for(String str:textArray)
        {
            wr.write(str+"\n");
        }
        wr.flush();
        wr.close();
    }

}
