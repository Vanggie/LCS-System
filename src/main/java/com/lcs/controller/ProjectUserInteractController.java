package com.lcs.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.lcs.domain.CommentList;
import com.lcs.service.CommentService;
import com.lcs.service.ProjectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.io.IOException;
import java.text.ParseException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

@Controller
public class ProjectUserInteractController {
    @Autowired
    private ProjectService projectService;

    @Autowired
    private CommentService commentService;

    @Autowired
    private ObjectMapper objectMapper;

    @RequestMapping(path="/commentShow")
    public @ResponseBody String getCommentList(@RequestParam("projectName") String projectName, @RequestParam("uploader") String uploader) throws IOException, ParseException {
        System.out.println("[Request] 'getCommentList' : "+ projectName  +" " + uploader);
        CommentList cmlist = commentService.getCommentList(projectName , uploader);
        String result = objectMapper.writeValueAsString(cmlist.getComment());
        System.out.println("[Request] 'getCommentList' returns : "+ result);
        return result;
    }
    @RequestMapping(path="/commentAdd")
    public @ResponseBody String addComment(@RequestBody Map<String,String> param) throws IOException {
        String uploader = param.get("uploader");
        String projectName = param.get("projectName");
        String content = param.get("content");
        String dateStr = param.get("date");
        String commentBy = param.get("commentby");
        System.out.println("[Request] 'addComment' : "+ projectName  + ": " + content);
        String result = commentService.addComment(projectName, uploader, commentBy, dateStr, content, null);
        System.out.println("[Request] 'getCommentList' returns : "+ result);
        return result;
    }
    @RequestMapping(path="/thumbUp")
    public @ResponseBody String thumbUp(@RequestBody Map<String,String> param){
        String uploader = param.get("uploader");
        String projectName = param.get("projectName");
        System.out.println("[Request] thumbUp "+uploader +" " + projectName);
        projectService.addThumbUp(projectName, uploader);
        return "success";
    }
}
