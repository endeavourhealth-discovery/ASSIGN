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

    // X.STR
    public Integer XSTR(String street, Integer like) throws SQLException
    {
        Integer in = 0;

        String e = "="; String p = "";
        if (like.equals(1)) {
            e = "like"; p = "%";
        }
        String q ="SELECT street from uprn_v2.uprn_main where street "+e+" '" + street +p+"'";
        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) {
            in = 1;
        }
        return in;
    }

    // OutOfArea
    public Integer inpost(String area, String qpost) throws SQLException
    {
        Integer in = 0;
        String q = "SELECT * FROM uprn_v2.uprn_dictionary where n1 = 'AREAS' and `data` = '"+area+"'";
        if (!qpost.isEmpty()) {
            q = "SELECT * FROM uprn_v2.uprn_dictionary where n1 = 'AREAS' and `data` = '"+qpost+"'";
        }

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        if (rs.next()) {in = 1;}
        preparedStatement.close();

        return in;
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

        preparedStatement.close();
        return "{}";
    }

    public void close() throws SQLException {
        connection.close();
    }
}