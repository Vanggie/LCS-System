package com.lcs.dao;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.dom4j.Document;
import org.dom4j.Element;

import com.lcs.domain.Comment;
import com.lcs.domain.CommentList;
import com.lcs.utils.XmlUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository
public class CommentDao {

    private static String DateFormat = "yyyy-MM-dd hh:mm";

    public List<Comment> recursivelyFindComments(List<Element> commentElements) throws ParseException {

        if(commentElements == null || commentElements.size() == 0) return null;
        ArrayList<Comment> commentList = new ArrayList<Comment>();
        for(Element commentElement : commentElements){
            Comment comment = new Comment();
            String commentby = commentElement.attributeValue("commentby");
            int id = Integer.parseInt(commentElement.attributeValue("id"));
            int level = Integer.parseInt(commentElement.attributeValue("level"));
            SimpleDateFormat sd = new SimpleDateFormat(DateFormat);
            Date date = new Date();
            date = sd.parse(commentElement.attributeValue("date"));
            String content = commentElement.getText();
            comment.setCommentby(commentby);
            comment.setId(id);
            comment.setLevel(level);
            comment.setDate(date);
            comment.setContent(content.replace("\n","").trim());
            List<Element> list = commentElement.elements("comment");
            List<Comment> subComments = recursivelyFindComments(list);
            if(subComments != null ) {
                comment.setSubComments(subComments);
            }
            commentList.add(comment);
        }
        return commentList;
    }

    // Get comments  output as Json String
    public String findAsJson(String projectName,String uploader) throws IOException, ParseException {
        String filename = "/" + "comments" + "/" + uploader + "/" + projectName +".xml";
        String cmjson="[";
        System.out.println(filename);
        XmlUtils xmlutils = new XmlUtils();
        Document doc= xmlutils.xmlread(filename);

        //get comment node;
        if(doc==null)
        {
            System.out.println("Document Load Error");
            return null;
        }

        Element e=(Element) doc.selectSingleNode("//comment-list[@uploader='"+uploader+"' and @projectName='"+projectName+"']");
        if(e==null)
        {
            return null;

        }
        //get all comment elements under comment-list element
        List<Element> list=e.elements("comment");

        List<Comment> cmlist = recursivelyFindComments(list);
        for(Comment comment: cmlist){
            cmjson = cmjson + comment.parseAsJson()+",";
        }

        cmjson = cmjson.substring(0,cmjson.length()-1);
        cmjson = cmjson+"]";
        return cmjson;
    }
    // Get comments  output as Json String
    public List<Comment> findAsList(String projectName,String uploader) throws IOException, ParseException {
        String filename = "/" + "comments" + "/" + uploader + "/" + projectName +".xml";
        System.out.println(filename);
        XmlUtils xmlutils = new XmlUtils();
        Document doc= xmlutils.xmlread(filename);

        //get comment node;
        if(doc==null)
        {
            System.out.println("Document Load Error");
            return null;
        }

        Element e=(Element) doc.selectSingleNode("//comment-list[@uploader='"+uploader+"' and @projectName='"+projectName+"']");
        if(e==null)
        {
            return null;

        }
        //get all comment elements under comment-list element
        List<Element> list=e.elements("comment");


        List<Comment> cmlist = recursivelyFindComments(list);
        return  cmlist;

    }

    // Add one new comment into comment list
    public boolean add(String projectName,String uploader,Comment newcomment, List<Integer> parentIds) throws IOException {
        String filename = "/" + "comments" + "/" + uploader + "/" + projectName +".xml";
        XmlUtils xmlutils = new XmlUtils();
        Document doc = xmlutils.xmlread(filename);
        //get comment node;
        Element parentElement = (Element) doc.selectSingleNode("//comment-list[@uploader='"+uploader+"' and @projectName='"+projectName+"']");
        if(parentElement == null)
        {
            System.out.println("Creating new root element in doc");
            parentElement = doc.addElement("comment-list");
            parentElement.setAttributeValue("uploader", uploader);
            parentElement.addAttribute("projectName", projectName);
        }
        List<Element> commentElements = parentElement.elements("comment");
        for(int i = 0; parentIds != null && i < parentIds.size(); i++){
            int curLevelId = parentIds.get(i);
            if(commentElements == null || commentElements.size() ==0) {
                System.out.println("provided parentIds cannot be found.");
                return false;//privided parentIds cannot be found.
            }
            parentElement = commentElements.get(curLevelId);
            commentElements = parentElement.elements("comment");
        }

        Element commentElement = parentElement.addElement("comment");
        commentElement.setAttributeValue("commentby", newcomment.getCommentby());
        SimpleDateFormat sd= new SimpleDateFormat(DateFormat);
        commentElement.setAttributeValue("date", sd.format(newcomment.getDate()));
        commentElement.setText(newcomment.getContent());
        commentElement.setAttributeValue("id", ""+(parentElement.elements("comment")==null?0:parentElement.elements("comment").size() - 1));
        commentElement.setAttributeValue("level", String.valueOf(parentIds==null ? 0 : parentIds.size() ) );

        ////Write files;
        try {
            xmlutils.xmlwrite(doc,filename);
        } catch (IOException e1) {
            throw new RuntimeException(e1+"  Wrting Comment Data Base Exception");
        }

        return true;
    }



    public boolean delete(String projectName,String uploader,int commentId, List<Integer> parentIds) throws IOException {
        String filename = "/" + "comments" + "/" + uploader + "/" + projectName +".xml";
        XmlUtils xmlutils = new XmlUtils();
        Document doc= xmlutils.xmlread(filename);
        //get comment node;
        //get comment node;
        Element parentElement = (Element) doc.selectSingleNode("//comment-list[@uploader='"+uploader+"' and @projectName='"+projectName+"']");
        if(parentElement == null)
        {
            return false;
        }
        List<Element> commentElements = parentElement.elements("comment");
        for(int i = 0; parentIds != null && i < parentIds.size(); i++){
            int curLevelId = parentIds.get(i);
            if(commentElements == null || commentElements.size() ==0) {
                System.out.println("provided parentIds cannot be found.");
                return false;//privided parentIds cannot be found.
            }
            parentElement = commentElements.get(curLevelId);
            commentElements = parentElement.elements("comment");
        }
        parentElement.remove(commentElements.get(commentId));

        xmlutils.xmlwrite(doc,filename);
        return true;
    }
}
