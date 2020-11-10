package com.lcs.junittest;
import com.lcs.dao.ProjectDao;
import com.lcs.domain.Project;
import com.mysql.jdbc.exceptions.jdbc4.MySQLIntegrityConstraintViolationException;
import org.apache.ibatis.io.Resources;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

class projectTest {
    @Test
    void testCRUDProject() throws Exception {
        //load config file
        InputStream in = Resources.getResourceAsStream("sqlMapConfig.xml");
        //create sql session factory
        SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(in);
        //get session
        SqlSession session = sqlSessionFactory.openSession();
        //get mapper
        ProjectDao projectdao = session.getMapper(ProjectDao.class);
        //create new project
        Project project = new Project();
        project.setProjectname("Omni3D");
        project.setAuthor("Jin");
        project.setUploader("Jin");
        try{
            projectdao.addProject(project);
            session.commit();
        }
        catch(Exception e){
            System.out.println("Project already exist");
        }

        
        //get project
        Project project2 =  projectdao.getProject(project);
        System.out.println(project2);
        
        //update project
        project2.setText(1);
        projectdao.updateProject(project2);
        session.commit();
        Project project3 =  projectdao.getProject(project);
        System.out.println(project3);
        
        //get list
        List<Project> projectList = projectdao.getProjectList(3,1);

        for(Project tmp:projectList){
            System.out.println(tmp);
        }
  //      projectdao.deleteProjectByName(project.getProjectname());
        
        session.commit();
        session.close();
        in.close();
    }

}