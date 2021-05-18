package org.endeavourhealth.uprnAlgorithm.repository;

import com.mysql.cj.jdbc.MysqlDataSource;

import java.io.*;
import java.sql.*;
import java.util.*;

public class Repository {

    private MysqlDataSource dataSource;
    private Connection connection;

    public Repository(Properties properties) throws SQLException {
        init( properties );
    }

    private void init(Properties props) throws SQLException {

    try {

	String url = props.getProperty("url");
        String username = props.getProperty("username");
        String pass = props.getProperty("password");

        dataSource = new MysqlDataSource();

        dataSource.setURL(url);
        dataSource.setUser(username);
        dataSource.setPassword(pass);

        dataSource.setReadOnlyPropagatesToServer(true);

        connection = dataSource.getConnection();

        }
        catch(Exception e)
        {
            System.out.println(e);
        }
    }

    public String GetUPRN() throws SQLException {

        // test that we can connect to the mysql database?
        String preparedSql = "SELECT * FROM uprn_v2.`uprn_dictionary` limit 10";
        PreparedStatement preparedStatement = connection.prepareStatement( preparedSql );

        ResultSet rs = preparedStatement.executeQuery();
        while (rs.next()) {
            String data = rs.getString("data");
            System.out.println(data);
        }

        return "{}";
    }

    public void close() throws SQLException {
        connection.close();
    }
}