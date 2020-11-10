package com.lcs.service;

import com.lcs.dao.ProjectDao;
import com.lcs.domain.Project;
import org.bytedeco.javacv.FFmpegFrameGrabber;
import org.bytedeco.javacv.Frame;
import org.bytedeco.javacv.Java2DFrameConverter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.io.*;
import java.util.*;

@Service
public class ProjectService {
    static int MAX_SIZE_TEXT=4096*20;
    @Autowired
    private ProjectDao projectdao;

    //get project map in one page
    public Map getProjectMap(Integer numItemsOnOnePage, Integer offset){
        System.out.println("Get project list to show, offset: " + offset);
        HashMap<String, Project> projectMap = new HashMap<String, Project>();
        List<Project> projectList = projectdao.getProjectList(numItemsOnOnePage, offset);
        for(Project curProject:projectList){
            projectMap.put(curProject.getProjectname(), curProject);
        }
        return projectMap;
    }

    public List<String> getProjectNameListByUploader(String uploader){
        return projectdao.getProjectNameListByUploader(uploader);
    }

    //get Total number of projects in the database
    public Integer getProjectCount(){
        return projectdao.getProjectCount();
    }

    public Map getFirstProjectTextDescription(Map<String,Project> projectMap, String path){
        //get text description for each project.
        Map<String, String> firstTextMap = new HashMap<String, String>();
        Set<Map.Entry<String, Project>> entrySet = projectMap.entrySet();
        for(Map.Entry<String,Project> entry:entrySet){
            if(entry.getValue().getText() > 0)
            {
                String uploader = entry.getValue().getUploader();
                String projectName = entry.getValue().getProjectname();
                try {
                    FileReader fr = new FileReader(path + "resource\\userdata\\" + uploader + "\\" + projectName + "\\text" + 1 + ".dat");
                    char[] cbuf = new char[MAX_SIZE_TEXT];
                    try {
                        fr.read(cbuf);
                        System.out.println(cbuf);
                        firstTextMap.put(projectName, String.valueOf(cbuf));
                    }
                    catch (Exception e){
                        System.out.println("[getFirstProjectTextDescription] Error reading file");
                    }
                }
                catch(Exception e){
                    System.out.println("[getFirstProjectTextDescription] File not found while reach "+
                            "resource\\userdata\\" + uploader + "\\" + projectName + "\\text" + 1 + ".dat");
                    continue;
                }
            }
        }
        return firstTextMap;
    }
    //add a text description file to project
    public boolean addTextToProject(String projectname, String uploader, String projectText, String path){
        Project project = projectdao.getProjectByNameAndUploader(projectname, uploader);
        if(project == null){
            return false;
        }
        else{
            project.setText( project.getText() + 1);
            try {
                FileWriter fw = new FileWriter(path + "resource\\userdata\\" + uploader + "\\" + projectname + "\\text" + project.getText() + ".dat");
                fw.write(projectText);
                fw.flush();
                fw.close();
                System.out.println("Add text to project "+projectname+" succeed");
                projectdao.updateProject(project);
                return true;
            }
            catch(Exception e){
                System.out.println("Add text to project "+projectname+" failed: " + e.getMessage());
                return false;
            }
        }
    }

    public boolean addFileToProject(String projectname, String uploader, MultipartFile multipartFile, String fileType, String contextPath) throws Exception
    {
        String orgFilename = multipartFile.getOriginalFilename();
        int ind = orgFilename.lastIndexOf(".");
        String fileExtension = orgFilename.substring(ind + 1);
        Project project = projectdao.getProjectByNameAndUploader(projectname, uploader);
        String path = contextPath + "resource\\userdata\\" + uploader +"\\" + projectname + "\\"+fileType+"\\";
        if(project == null){
            return false;
        }
        else{
            //update project counts
            int newFileCount = 0;
            String filename = null;
            switch(fileType){
                case("image"):
                    project.setPic( project.getPic() + 1);
                    newFileCount = project.getPic();
                    filename = fileType + String.format("%04d" , newFileCount )+ "." + fileExtension;
                    if(newFileCount == 1) project.setFirstPicName(filename);
                    break;
                case("movie"):
                    project.setMov( project.getMov() + 1);
                    newFileCount = project.getMov();
                    filename = fileType + String.format("%04d" , newFileCount )+ "." + fileExtension;
                    if(newFileCount == 1) project.setFirstMovName(filename);
                    break;
                case("attachment"):
                    project.setAttachment( project.getAttachment() + 1);
                    newFileCount = project.getAttachment();
                    filename = fileType + String.format("%04d" , newFileCount )+ "." + fileExtension;
                    if(newFileCount == 1) project.setFirstAttachmentName(filename);
                    break;
                default:
            }
            try {


                File file = new File(path);
                if(!file.exists()){
                    file.mkdir();
                }
                multipartFile.transferTo(new File(path, filename));

                //Generate preview image for movie
                if (fileType.equals( "movie")) {
                    FFmpegFrameGrabber frameGrabber = new FFmpegFrameGrabber(path + filename);
                    frameGrabber.start();
                    Java2DFrameConverter converter = new Java2DFrameConverter();
                    ImageIO.write(converter.convert(frameGrabber.grab()), "png", new File(path + filename + ".png"));
                    frameGrabber.stop();
                    System.out.println("Add preview image for movie : " + orgFilename +" to project "+projectname+" succeed");
                }

                System.out.println("Add file " + orgFilename +" to project "+projectname+" succeed");

                projectdao.updateProject(project);
                return true;
            }
            catch(Exception e){
                e.printStackTrace();
                throw e;
            }
        }
    }
    public ArrayList<String> getProjectFileNames(String projectname, String uploader, String contextPath, String fileType){
        System.out.println("[service] getProjectFileNames ");
        Project project = projectdao.getProjectByNameAndUploader(projectname, uploader);
        if(project == null){
            System.out.println("Project not found");
            return null;
        }
        else
        {
            ArrayList<String> result = new ArrayList<String>();
            File path = new File(contextPath + "resource\\userdata\\" + uploader + "\\" + projectname + "\\"+ fileType +"\\");
            if(!path.exists()){
                System.out.println("Path do not exist");
                return null;
            }
            File[] files = path.listFiles();
            System.out.println(path.getPath());
            for(int i = 0; i < files.length; i++)
            {
                if(!(fileType.equals("movie") && files[i].getName().endsWith(".png"))) {
                    result.add(files[i].getName());
                }
            }
            System.out.println("Get " + fileType + " under Project " + projectname + ":" + result);
            return result;
        }
    }

    public ArrayList<String> getAllTextDescription(String projectname, String uploader, String contextPath) throws FileNotFoundException {
        Project project = projectdao.getProjectByNameAndUploader(projectname, uploader);
        if(project == null){
            return null;
        }
        else
        {
            ArrayList<String> textArray = new ArrayList<String>();
            for(int i = 2 ; i <= project.getText(); i++){
                FileReader fr = new FileReader(contextPath + "resource\\userdata\\" + uploader + "\\" + projectname + "\\text" + i + ".dat");
                char[] cbuf = new char[MAX_SIZE_TEXT];
                try {
                    fr.read(cbuf);
                    System.out.println(cbuf);
                    textArray.add( String.valueOf(cbuf));
                }
                catch(Exception e){
                    System.out.println("[getAllTextDescription] Error reading file: " + "text" + i + ".dat");
                }
            }
            return textArray;
        }
    }

    //project user interact service
    public String addThumbUp(String projectName, String uploader){
         Project project = projectdao.getProjectByNameAndUploader(projectName, uploader);
         project.setThumbUp(project.getThumbUp());
         project.setWeight(project.getWeight());
         projectdao.updateProject(project);
         return "success";
    }
}
