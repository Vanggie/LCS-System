package com.lcs.dao;

import com.lcs.domain.Project;
import org.apache.ibatis.annotations.*;
import org.springframework.stereotype.Repository;

import java.util.List;
@Repository
public interface ProjectDao {
    @Select("select count(*) from project")
    public Integer getProjectCount();

    @Select("select * from project ORDER BY weight ASC LIMIT ${numItemsOnOnePage} OFFSET ${offset};")
    public List<Project> getProjectList(@Param("numItemsOnOnePage") Integer numItemsOnOnePage, @Param("offset") Integer offset);

    @Select("select projectname from project where uploader = \"${uploader}\" ORDER BY weight ASC;")
    public List<String> getProjectNameListByUploader(@Param("uploader") String uploader);

    @Insert("insert into project (projectname, uploader, author, text, pic, mov, attachment, thumbUp, weight) "+
    "values (#{projectname}, #{uploader}, #{author}, #{text}, #{pic}, #{mov}, #{attachment}, #{thumbUp}, #{weight})")
    public void addProject(Project project);

    @Select("select * from project "+
            "where projectname = #{projectname} and author = #{author}")
    public Project getProject(Project project);

    @Select("select * from project "+
            "where projectname = #{projectname}")
    public List<Project> getProjectByName(String projectname);

    @Select("select * from project "+
            "where projectname = #{projectname} and uploader = #{uploader}")
    public Project getProjectByNameAndUploader(@Param("projectname") String projectname, @Param("uploader") String uploader);


    @Update("update project " +
            "SET text = #{text}, pic = #{pic}, mov = #{mov}, attachment = #{attachment}, thumbUp = #{thumbUp}, weight = #{weight}" +
            " WHERE projectname = #{projectname} and author = #{author};")
    public void updateProject(Project project);

    @Delete("delete from project where projectname = #{projectname} and author = #{author};")
    public void deleteProject(Project project);

    @Delete("delete from project where projectname = #{projectname};")
    public void deleteProjectByName(String projectname);
}
