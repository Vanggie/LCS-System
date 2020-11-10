package com.lcs.service;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import com.lcs.dao.CommentDao;
import com.lcs.domain.Comment;
import com.lcs.domain.CommentList;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service("commentService")
public class CommentService {
    /*
     * {"employees":[
      {"firstName":"John", "lastName":"Doe"},
      {"firstName":"Anna", "lastName":"Smith"},
      {"firstName":"Peter", "lastName":"Jones"}
      ]}
     */
    @Autowired
    private CommentDao commentDao;

    SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd hh:mm");
    public String getCommentListAsJson(String projectName,String uploader) throws IOException, ParseException {
        return commentDao.findAsJson(projectName, uploader);

    }

    public CommentList getCommentList(String projectName,String uploader) throws IOException, ParseException {
        System.out.println("[Service] getCommentList");
        List<Comment> cmlist = commentDao.findAsList(projectName, uploader);
        CommentList commentList = new CommentList();
        commentList.setProjectName(projectName);
        commentList.setUploader(uploader);
        commentList.setComment(cmlist);
        return commentList;
    }

    public String deleteComment(String projectName,String uploader, int id, List<Integer> parentIds) throws IOException {
        //use CommentDao to access database;
        CommentDao cd=new CommentDao();
        cd.delete(uploader, projectName, id, parentIds);
        return "success";
    }

    public String addComment(String projectName,String uploader,String commentby,String datestr,String content, List<Integer> parentIds) throws IOException {
        //build a comment;
        Comment cm = new Comment();
        if(commentby==null || commentby.trim()=="")
        {
            return new String("Comment-by is invalid!");
        }
        cm.setCommentby(commentby);

        if(content ==null || content.trim()=="")
        {
            return new String("Comment-content is invalid!");
        }
        cm.setContent(content);

        Date date=new Date();
        if(datestr==null || datestr.trim()=="")
        {
            return new String("Date is invalid!");
        }
        else
        {

            try {
                date=sdf.parse(datestr);
            } catch (ParseException e) {
                return new String("Date Type invalid!");
            }
        }
        cm.setDate(date);

        ///update the databse;
        CommentDao cd = new CommentDao();
        if(cd.add(projectName,uploader,cm, parentIds) == false)
        {
            return new String("Adding failure!!");
        }
        return new String("success");
    }

    //get a single comment!!!!
    public String getCommentAsJson(String projectName,String uploader,String commentby,String datestr) throws IOException, ParseException {
        List<Comment> cmlist = commentDao.findAsList(projectName, uploader);
        if(cmlist==null)
        {
            return null;
        }
        if(cmlist!=null)
        {
            for(Comment cm:cmlist)
            {
                if(cm.getCommentby() == commentby&&sdf.format(cm.getDate())==datestr)
                    return cm.parseAsJson();

            }
        }
        return null;
    }
}
