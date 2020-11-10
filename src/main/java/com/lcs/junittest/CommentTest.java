package com.lcs.junittest;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.lcs.domain.Comment;
import com.lcs.domain.CommentList;
import com.lcs.service.CommentService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.springframework.core.io.ClassPathResource;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

public class CommentTest {
    private ApplicationContext context;
    private CommentService service;

    @BeforeEach
    void init()
    {
        context = new ClassPathXmlApplicationContext("classpath:applicationContext.xml");
        service = (CommentService) context.getBean("commentService");
    }
    @Test
    void testCRUDCommentQuery() throws Exception {
        String result = service.getCommentListAsJson("Omni3D", "Jin");
        System.out.println(result);
        CommentList cmlist = service.getCommentList("Omni3D","Jin");
        ObjectMapper objectMapper = new ObjectMapper();
        String cmlistJson = objectMapper.writeValueAsString(cmlist.getComment());
        System.out.println(cmlistJson);
        assertNotNull(cmlist);
        //System.out.println(cmlist);
        assertNotNull(result);
        result = service.getCommentListAsJson("Omni3D", "null");

        assertNull(result);
    }



    @Test//add new comment
    void testCRUDCommentAdd() throws Exception {
        ApplicationContext context = new ClassPathXmlApplicationContext("classpath:applicationContext.xml");
        CommentService service = (CommentService) context.getBean("commentService");
        //testcase 1
        String projectName = "Omni3D";
        String uploader = "Jin";
        String commentby = "Jin";
        String datestr = "1989-08-24 11:11";
        String content = "TestAdd";
        List<Integer> parentIds = new ArrayList<>(Arrays.asList(1,0 ,0));
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd hh:mm");
        Comment expComment = new Comment(commentby,0,3, sdf.parse(datestr), content, null);


        service.addComment(projectName, uploader, commentby, datestr, content, parentIds);
        CommentList commentList = service.getCommentList(projectName, uploader);
        assertNotNull(commentList);
        List<Comment> list = commentList.getComment();
        assertNotNull(list);
        Comment actComment = null;
        for(int i = 0 ; parentIds != null && i < parentIds.size(); i++){
            int parentId = parentIds.get(i);
            if(list == null) System.out.println(actComment);
            assertNotNull(list, "" + i + actComment);
            actComment = list.get(parentId);
            assertNotNull(actComment);
            list = actComment.getSubComments();
        }
        actComment = list.get(list.size() - 1);
        assertEquals(expComment.getCommentby(), actComment.getCommentby());
        assertEquals(expComment.getContent(), actComment.getContent());
        assertEquals(expComment.getId(), actComment.getId());
        assertEquals(expComment.getLevel(), actComment.getLevel());
        assertEquals(expComment.getSubComments(), actComment.getSubComments());
        assertEquals(expComment.getDate(), actComment.getDate());
        //test delete
        service.deleteComment(projectName, uploader, 0, parentIds);

        //testcase 2, add to an empty File;
        projectName = "Omni2D";
        uploader = "Jin";
        commentby = "Jin";
        datestr = "1989-08-24 11:11";
        content = "TestAdd";
        sdf = new SimpleDateFormat("yyyy-MM-dd hh:mm");
        expComment = new Comment(commentby,0,0, sdf.parse(datestr), content, null);

        service.addComment(projectName, uploader, commentby, datestr, content, null);
        commentList = service.getCommentList(projectName, uploader);
        assertNotNull(commentList);
        list = commentList.getComment();
        assertNotNull(list);
        assertEquals(1, list.size());
        actComment = list.get(0);
        assertEquals(expComment.getCommentby(), actComment.getCommentby());
        assertEquals(expComment.getContent(), actComment.getContent());
        assertEquals(expComment.getId(), actComment.getId());
        assertEquals(expComment.getLevel(), actComment.getLevel());
        assertEquals(expComment.getSubComments(), actComment.getSubComments());
        assertEquals(expComment.getDate(), actComment.getDate());
        service.deleteComment(projectName, uploader, 0, null);


    }
}
