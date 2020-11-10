package com.lcs.junittest;
import com.lcs.dao.UserDao;
import com.lcs.domain.User;
import com.mysql.jdbc.exceptions.jdbc4.MySQLIntegrityConstraintViolationException;
import org.apache.ibatis.io.Resources;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.InputStream;

import static org.junit.jupiter.api.Assertions.assertEquals;

class UserTest {
    @Test
    void testCRUDUser() throws Exception {
        //load config file
        InputStream in = Resources.getResourceAsStream("sqlMapConfig.xml");
        //create sql session factory
        SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(in);
        //get session
        SqlSession session = sqlSessionFactory.openSession();
        //get mapper
        UserDao userdao = session.getMapper(UserDao.class);
        //create new user
        User usr = new User();
        usr.setUsername("Jin");
        usr.setPassword("123");

        usr.setEmail("jwang186@jhu.edu");
        usr.setPhone("4432404879");
        usr.setAddress("70 Queens Way");
        usr.setRemarks("Fluids, pressure");

        //add new user to sql database
        try {
            userdao.addUser(usr);
        }
        catch(Exception e){
            System.out.println("User Already exist");
        }
        System.out.println(usr);
        session.commit();
        User usr2 = userdao.findUser(usr.getUsername());
       // assertEquals(usr, usr2);
        //Update user's phone number
        usr.setPhone("9805521211");
        userdao.updateUser(usr);
        session.commit();
        User usr3 = userdao.findUser(usr.getUsername());
       // assertEquals(usr, usr3);
        //delete user
       // userdao.deleteUser(usr.getUsername());
        session.commit();
        session.close();
        in.close();
    }

}
