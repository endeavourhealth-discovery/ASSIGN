package org.endeavourhealth.uprnAlgorithm.repository;

import com.mysql.cj.jdbc.MysqlDataSource;

import java.io.*;
import java.sql.*;
import java.util.*;

import static org.endeavourhealth.uprnAlgorithm.common.uprnCommon.*;

public class Repository {

    private MysqlDataSource dataSource;
    private Connection connection;

    public String adrec;
    public String commercials;
    public String processId;

    public Repository(Properties properties) throws SQLException {
        init( properties );
    }

    private void init(Properties props) throws SQLException {

    try {

	    String url = props.getProperty("url");
        String username = props.getProperty("username");
        String pass = props.getProperty("password");

        commercials= props.getProperty("commercials");
        processId = props.getProperty("process_id");

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

    public String QueryDictionary(String node, String word) throws SQLException
    {
        String data = "";

        word = word.replaceAll("'","''");

        String q= "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = '"+node+"' and n2='" + word + "'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) {
            data = rs.getString("data");
            if (data.isEmpty()) data = rs.getString("n1");
        }

        preparedStatement.close();

        return data;
    }

    public Integer QueryIndexes(String data, String column) throws SQLException
    {
        Integer in = 0;

        data = data.replace("'", "''");

        // select post from uprn_v2.uprn_main WHERE post = 'ig110rf'
        String q = "SELECT "+column+" FROM uprn_v2.uprn_main WHERE "+column+" = '" +data+ "'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) {in=1;}

        return in;
    }

    public Integer floor(String floor) throws SQLException
    {
        Integer n = 0;

        floor = floor.replace("'", "''");

        String q ="SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'FLOOR' and n2 = '"+floor+"'";

        System.out.println(q);

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        if (rs.next()) { n = 1; }
        preparedStmt.close();

        return n;
    }


    public Integer isroad(String text) throws SQLException {
        Integer n = 0;

        text = text.replace("'", "''");

        String q= "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'ROAD' and n2='"+text+"'";

        System.out.println(q);

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        if (rs.next()) { n = 1; }

        preparedStmt.close();

        return n;
    }

    public Integer TOWN(String data) throws SQLException {
        Integer n = 0;

        data = data.replace("'", "''");

        String q = "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'TOWN' and data='"+data+"'";

        System.out.println(q);

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        if (rs.next()) {
            n = 1;
        }

        preparedStmt.close();

        return n;
    }

    public Integer FLAT(String text) throws SQLException {
        Integer n = 0;

        String q = "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'FLAT' and n2='"+text+"'";

        System.out.println(q);

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        if (rs.next()) {
            n = 1;
        }

        preparedStmt.close();

        return n;
    }

    public Integer VERTICALS(String text) throws SQLException {
        Integer n = 0;

        text = text.replace("'","''");

        String q = "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'VERTICALS' and n2='"+text+"'";

        System.out.println(q);

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        if (rs.next()) {
            n = 1;
        }

        preparedStmt.close();

        return n;
    }

    public Integer COURT(String text) throws SQLException {
        Integer n = 0;

        String q = "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'COURT' and n2='"+text+"'";

        System.out.println(q);

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        if (rs.next()) {
            n = 1;
        }

        preparedStmt.close();

        return n;
    }

    public Integer BUILDING(String text) throws SQLException {
        Integer n = 0;

        String q = "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'BUILDING' and n2='"+text+"'";

        System.out.println(q);

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        if (rs.next()) {
            n = 1;
        }

        preparedStmt.close();

        return n;
    }

    public Integer ROAD(String text) throws SQLException {
        Integer n = 0;

        String q = "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'ROAD' and n2='"+text+"'";

        System.out.println(q);

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        if (rs.next()) {
            n = 1;
        }

        preparedStmt.close();

        return n;
    }

    public Integer hasflat(String text) throws SQLException {
        Integer hasflat = 0;
        String q = "SELECT * FROM uprn_v2.`uprn_dictionary` WHERE n1='FLAT'";

        System.out.println(q);

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();

        while (rs.next()) {
            String word = rs.getString("n2");
            if ((" "+text+" ").contains(" "+word+ " ")) {
                hasflat = 1;
            }
        }

        return hasflat;
    }

    public Integer isflat(String text) throws SQLException {
        Integer n = 0;

        if (Piece(text, " ",1 ,1).equals("tower") && RegEx(Piece(text, " ",2, 2),"^[0-9][a-z]+$").equals(10)) {
            return 0;
        }

        String q = "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'FLAT'";

        System.out.println(q);

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        while (rs.next()) {
            String word = rs.getString("n2");
            if (Piece(text," ",1,1).equals(word)) {
                n = 1;
            }
        }

        if (RegEx(text, "^[a-z]+( )\\w+$").equals(1) && floor(text).equals(1)) {n=1;}

        return n;
    }

    public Integer QueryFlat(String text) throws SQLException {
        Integer n = 0;
        String q = "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'FLAT' and n2='"+text+"'";

        System.out.println(q);

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        while (rs.next()) {
            String word = rs.getString("n2");
            if (Piece(text," ",1,1).equals(word)) {
                n = 1;
            }
        }
        // is floor
        // i text?1l.l1" ".e,$d(^UPRNS("FLOOR",text)) q 1
        // ^[a-z]+( )\w+$
        if (RegEx(text, "^[a-z]+( )\\w+$").equals(1) && floor(text).equals(1)) {n=1;}
        preparedStmt.close();

        return n;
    }

    public String flat(String text) throws SQLException {
        String q= "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'FLAT'";

        System.out.println(q);

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();

        while (rs.next()) {
            String word = rs.getString("n2");
            if (text.contains(word+" ")) {
                String a = Piece(text, word+" ",1, 1);
                String b = Piece(text, word+" ", 2, 20);
                text = a + b;
            }
        }

        preparedStmt.close();

        // for  q:($e(text)'="0")  s text=$e(text,2,50)
        for (;;){
            if (!text.substring(0, 0).equals("0")) {break;}
            text = text.substring(1,49);
        }

        // Flat at end
        String p[] = text.split(" ",-1);
        if (indexInBound(p, 1)) {
            // get last piece
            String flat = p[p.length-1];
            // flat exist in uprn-s?
            q= "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'FLAT' and n2='"+flat+"'";

            System.out.println(q);

            preparedStmt = connection.prepareStatement(q);
            rs = preparedStmt.executeQuery();
            // flat at end
            if (rs.next()) {
                //text = rs.getString("n2");
                text = Piece(text, " ", 1, CountPieces(text, " ")-1);
            }
        }

        preparedStmt.close();

        return text;
    }

    public Integer X1$D1(String tpost) throws SQLException
    {
        Integer in = 0;

        String q = "select * from uprn_v2.uprn_main where node='X1' and post='"+tpost+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        if (rs.next()) { in = 1; }
        preparedStatement.close();
        return in;
    }

    public Integer X5$D1(String tpost, String tstreet, String tflat) throws SQLException
    {
        Integer in = 0;
        String q ="select * from uprn_v2.uprn_main where node='X5' and post='"+tpost+"' ";
        q = q + "and street='"+tstreet+"' ";
        q = q + "and flat = '"+tflat+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        if (rs.next()) { in = 1; }
        preparedStatement.close();
        return in;
    }

    public Integer X5$D2(String tpost, String tstreet) throws SQLException
    {
        Integer in = 0;
        String q ="select * from uprn_v2.uprn_main where node='X5' and post='"+tpost+"' and street='"+tstreet+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        if (rs.next()) { in = 1; }
        preparedStatement.close();

        return in;
    }

    public Integer X5$D3(String tpost, String tstreet, String i, String tbuild, String tflat) throws SQLException
    {
        Integer in = 0;

        String q = "select * from uprn_v2.uprn_main where node='X5' and post='"+tpost+"' and street='"+tstreet+"' and bno='"+i+"' ";
        q = q + "and build='"+tbuild+"' and flat='"+tflat+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        if (rs.next()) { in = 1; }
        preparedStatement.close();

        return in;
    }

    public Integer X5$D4(String tpost, String tstreet, String tbno) throws SQLException
    {
        Integer in = 0;

        String q = "select * from uprn_v2.uprn_main where node='X5' and post='"+tpost+" and street='"+tstreet+"' and bno='"+tbno+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        if (rs.next()) { in = 1; }
        preparedStatement.close();

        return in;
    }

    public Integer X5$D5(String tpost, String tstreet, String tbno) throws SQLException
    {
        Integer in = 0;

        // builing and flat is null check
        String q = "select * from uprn_v2.uprn_main where node='X5' and post='"+tpost+"' and street='"+tstreet+"' and bno='"+tbno+"' ";
        q = q+"and build='' and flat=''";

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        if (rs.next()) { in = 1; }
        preparedStatement.close();

        return in;
    }

    public Integer FLATEXTRA$D(String text) throws SQLException
    {
        Integer in = 0;

        String q = "select * from uprn_v2.uprn_dictionary where n1='FLATEXTRA' and n2='"+text+"'";

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        if (rs.next()) { in = 1; }
        preparedStatement.close();

        return in;
    }

    public Integer TBEST$D1() throws SQLException
    {
        Integer in = 0;

        String q = "select * from uprn_v2.tbest where job='"+this.processId+"'";

        PreparedStatement preparedStmt = connection.prepareStatement(q);
        ResultSet rs = preparedStmt.executeQuery();
        if (rs.next()) { in = 1; }
        preparedStmt.close();

        return in;
    }

    public Integer TBEST$D2(String matchrec) throws SQLException
    {
        Integer in = 0;

        String q = "SELECT * FROM uprn_v2.tbest where data='"+matchrec+"' and job="+this.processId;

        PreparedStatement preparedStmt = connection.prepareStatement(q);
        ResultSet rs = preparedStmt.executeQuery();
        if (rs.next()) { in = 1; }
        preparedStmt.close();

        return in;
    }

    public String TBEST$GET(String matchrec) throws SQLException
    {
        String ret = "";

        String q = "SELECT * FROM uprn_v2.tbest where data='"+matchrec+"' and job="+this.processId;

        PreparedStatement preparedStmt = connection.prepareStatement(q);
        ResultSet rs = preparedStmt.executeQuery();

        if (rs.next()) {
            ret = rs.getString("id")+"~"+rs.getString("matchrec")+"~"+rs.getString("bno")+"~"+rs.getString("build")+"~"+rs.getString("flat")+"~"+rs.getString("post");
        }

        preparedStmt.close();
        return ret;
    }

    public void TBEST$Kill() throws SQLException
    {
        String job = getProcessId();
        String q = "delete from uprn_v2.tbest where job = ?";

        PreparedStatement preparedStmt = connection.prepareStatement(q);
        preparedStmt.setString(1,job);
        preparedStmt.execute();

        preparedStmt.close();
    }

    public void TBEST$Set(String matchrec, String tbno, String tbuild, String tflat, String post) throws SQLException
    {
        // this might need to be an upsert
        String job = getProcessId();
        String q = "insert into uprn_v2.tbest (matchrec, bno, build, flat) values(?,?,?,?)";

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        preparedStmt.setString(1, matchrec);
        preparedStmt.setString(2, tbno);
        preparedStmt.setString(3, tbuild);
        preparedStmt.setString(4, tflat);

        preparedStmt.execute();
        preparedStmt.close();
    }

    // $D(^UPRNX("X3",tbuild,tflat))
    public Integer X3$Data(String tbuild, String tflat) throws SQLException
    {
        Integer in = 0;

        String q = "SELECT * FROM uprn_v2.uprn_main where node='X3' and build='"+tbuild+"' and flat='"+tflat+"' limit 1";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) {
            in = 1;
        }

        preparedStatement.close();

        return in;
    }

    public Integer X3$D1(String post, String tstreet, String tbno, String tbuild, String tflat) throws SQLException
    {
        Integer in = 0;

        String q ="select * from uprn_v2.uprn_main where node='X3' and post='"+post+"' and street='"+tstreet+"' and bno='"+tbno+"' ";
        q = q + "and build='"+tbuild+"' and flat='"+tflat+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) { in = 1;}

        preparedStatement.close();

        return in;
    }

    public Integer X3$D2(String tstreet, String tbno) throws SQLException
    {
        Integer in = 0;

        String q ="select * from uprn_v2.uprn_main where node='X3' and street='"+tstreet+"' and bno='"+tbno+"'";
        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) { in = 1;}

        preparedStatement.close();

        return in;
    }

    public Integer X3$D3(String tstreet) throws SQLException
    {
        Integer in = 0;

        String q = "select * from uprn_v2.uprn_main where node='X3' and street='"+tstreet+"'";
        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        if (rs.next()) { in = 1;}
        preparedStatement.close();

        return in;
    }

    // $d(^UPRNX("X5",tpost,tstreet,tbno,tbuild,tflat))
    public Integer X5(String tpost, String tstreet, String tbno, String tbuild, String tflat) throws SQLException
    {
        Integer in = 0;

        String q = "SELECT * FROM uprn_v2.uprn_main where node='X5' and post='"+tpost+"' ";
        q = q + "and street='"+tstreet+"' and bno='"+tbno+"' and build='"+tbuild+"' ";
        q = q + "and flat='"+tflat+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) {
            in = 1;
        }

        preparedStatement.close();

        return in;
    }

    // X $D(^UPRNX("X",indrec))
    public Integer X(String indrec) throws SQLException
    {
        Integer in = 0;

        String q = "SELECT * FROM uprn_v2.uprn_main where node='X' and indrec='"+indrec+"' limit 1";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) {
            in = 1;
        }

        preparedStatement.close();

        return in;
    }

    // X.BLD
    public Integer XBLD(String building, Integer like) throws SQLException
    {
        Integer in = 0;

        String e = "="; String p = ""; String limit = " limit 1";
        if (like.equals(1)) {
            e = "like"; p = "%";
            limit = "";
        }

        building = building.replace("'", "''");

        String q ="SELECT street from uprn_v2.uprn_main where build "+e+" '" + building +p + "'"+limit;

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) {
            in = 1;
        }

        preparedStatement.close();
        return in;
    }

    // X.STR
    public Integer XSTR(String street, Integer like) throws SQLException
    {
        Integer in = 0;

        //System.out.println("["+street+"]");
        if (street.isEmpty()) {
            //System.out.println("street is null!");
            return 0;
        }

        String e = "="; String p = ""; String limit = " limit 1";

        // test - please remove
        //limit = "";

        if (like.equals(1)) {
            e = "like"; p = "%";
            limit = "";
        }

        street = street.replace("'", "''");

        String q ="SELECT street from uprn_v2.uprn_main where street "+e+" '" + street +p+"' "+limit;

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) {
            in = 1;
        }

        preparedStatement.close();

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

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        if (rs.next()) {in = 1;}
        preparedStatement.close();

        return in;
    }

    public String GetUPRN() throws SQLException {
        // test that we can connect to the mysql database?
        String preparedSql = "SELECT * FROM uprn_v2.`uprn_dictionary` limit 10";

        System.out.println(preparedSql);

        PreparedStatement preparedStatement = connection.prepareStatement( preparedSql );

        ResultSet rs = preparedStatement.executeQuery();
        while (rs.next()) {
            String data = rs.getString("data");
            // System.out.println(data);
        }

        preparedStatement.close();
        return "{}";
    }

    public List<List<String>> BESTFIT() throws SQLException
    {
        List<List<String>> result = new ArrayList<>();

        String q = "SELECT * FROM uprn_v2.uprn_dictionary";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        while (rs.next()) {
            String matchrec = rs.getString("data");
            String id = rs.getString("n2");
            List<String> row = new ArrayList<>();
            row.add(matchrec);
            row.add(id);
            result.add(row);
        }

        preparedStatement.close();
        return result;
    }

    public Integer FLOOR(String vertical) throws SQLException {
        Integer in = 0;

        String q = "select * from uprn_v2.uprn_dictionary where n2='"+vertical+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) in = 1;

        preparedStatement.close();
        return in;
    }

    public Integer $Dfla4$suffix(String flat, String suffix) throws SQLException
    {
        Integer in = 0;

        String q = "select * from uprn_v2.uprn_dictionary where n1='FLOOR' and n2='"+flat+"' and n3='"+suffix+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) in = 1;

        preparedStatement.close();
        return in;
    }

    public Integer VERTICALSX(String flat, String tflat) throws SQLException
    {
        Integer in = 0;

        String q = "select * from uprn_v2.uprn_dictionary where n1='VERTICALSX' and n2='"+flat+"' and n3='"+tflat+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) in = 1;

        preparedStatement.close();
        return in;
    }

    public List<List<String>> List$Flats(String tpost, String tstreet, String tbno, String tbuild) throws SQLException
    {
        List<List<String>> result = new ArrayList<>();

        String q = "select distinct flat from uprn_v2.uprn_main where node='X5' and post='"+tpost+"' and street='"+tstreet+"' and bno='"+tbno+"' and build='"+tbuild+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        while (rs.next()) {
            List<String> row = new ArrayList<>();
            String build = rs.getString("build");
            row.add(build);
            result.add(row);
        }

        preparedStatement.close();

        return result;
    }

    public List<List<String>> List$Buildings(String tpost, String tstreet, String tbno) throws SQLException
    {
        List<List<String>> result = new ArrayList<>();

        String q = "select distinct build from uprn_v2.uprn_main where node='X5' and post='"+tpost+"' and street='"+tstreet+"' and bno='"+tbno+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        while (rs.next()) {
            List<String> row = new ArrayList<>();
            String build = rs.getString("build");
            row.add(build);
            result.add(row);
        }

        preparedStatement.close();
        return result;
    }

    public List<List<String>> List$BuildingNumbers(String tpost, String tstreet) throws SQLException
    {
        List<List<String>> result = new ArrayList<>();

        String q = "select distinct bno from uprn_v2.uprn_main where node='X5' and post='"+tpost+"' and street='"+tstreet+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        while (rs.next()) {
            List<String> row = new ArrayList<>();
            String bno = rs.getString("bno");
            row.add(bno);
            result.add(row);
        }

        preparedStatement.close();

        return result;
    }

    public List<List<String>> match48Rs1(String tpost, String tstreet, String tbuild, String tbno, String tflat) throws SQLException
    {
        // use a hash table instead of an array (or try distinct)
        List<List<String>> result = new ArrayList<>();

        String q ="select distinct street, bno, build from uprn_v2.uprn_main where node = 'X5' and post='"+tpost+"' and street='"+tstreet+"' and bno='"+tbno+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        while (rs.next()) {
            String build = rs.getString("build");
            if (!tbuild.contains(build)) continue;
            if (tflat.isEmpty()) tflat = Piece(tbuild," "+build,1,1);
            List<String> row = new ArrayList<>();
            row.add(build);
            row.add(tflat);
            result.add(row);
        }

        preparedStatement.close();
        return result;
    }

    public List<List<String>> match48Rs2(String tpost, String tstreet, String tbno, String build) throws SQLException
    {
        List<List<String>> result = new ArrayList<>();

        String q = "select distinct post, street, bno, build, flat from uprn_v2.uprn_main where node = 'X5' and post='"+tpost+"' and street='"+tstreet+"' and bno='"+tbno+"' and build='"+build+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        while (rs.next()) {
            List<String> row = new ArrayList<>();
            String flat = rs.getString("flat");
            row.add(flat);
            result.add(row);
        }

        preparedStatement.close();
        return result;
    }

    // called from bestfitn
    public List<List<String>> bestfitn(String tbuild, String tflat, String tpost) throws SQLException
    {
        List<List<String>> result = new ArrayList<>();

        String q = "select dictinct post from uprn_v2.uprn_main where node = 'X3' and build='"+tbuild+"' and flat='"+tflat+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        while (rs.next()) {
            List<String> row = new ArrayList<>();
            String post = rs.getString("post");
            if (post.equals(tpost)) continue;
            row.add(post);
            result.add(row);
        }

        preparedStatement.close();
        return result;
    }

    public List<List<String>> X3farpost(String tstreet) throws SQLException
    {
        List<List<String>> result = new ArrayList<>();

        String q = "select * from uprn_v2.uprn_main where node='X3' and street='"+tstreet+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        while (rs.next()) {
            List<String> row = new ArrayList<>();
            String bno = rs.getString("bno");
            String post = rs.getString("post");
            row.add(bno);
            row.add(post);
            result.add(row);
        }

        preparedStatement.close();
        return result;
    }

    // *** POSSIBLY REDUNDANT ***
    public List<List<String>> X3$O1(String tstreet) throws SQLException
    {
        List<List<String>> result = new ArrayList<>();

        String q = "select distinct bno from uprn_v2.uprn_main where node = 'X3' and street='"+tstreet+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        while (rs.next()) {
            List<String> row = new ArrayList<>();
            String bno = rs.getString("bno");
            row.add(bno);
            result.add(row);
        }

        preparedStatement.close();
        return result;
    }

    public List<List<String>> match48Rs3(String tstreet, String tbno, String tpost) throws SQLException
    {
        List<List<String>> result = new ArrayList<>();

        String q = "select distinct post, street, bno from uprn_v2.uprn_main where node = 'X3' and bno='"+tbno+"' and street='"+tstreet+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        while (rs.next()) {
            List<String> row = new ArrayList<>();
            String post = rs.getString("post");
            if (post.equals(tpost)) continue;
            row.add(post);
            result.add(row);
        }

        preparedStatement.close();
        return result;
    }

    public List<List<String>> match33a(String tpost, String tstreet, String tflat, String build) throws SQLException
    {
        List<List<String>> result = new ArrayList<>();

        String q = "select * from uprn_v2.uprn_main where node = 'X5' and post='"+tpost+"' and street='"+tstreet+"' and bno='"+tflat+"' and build='"+build+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        while (rs.next()) {
            String flat = rs.getString("flat");
            List<String> row = new ArrayList<>();
            row.add(flat);
            result.add(row);
        }

        preparedStatement.close();

        return result;
    }

    public List<List<String>> match33(String tpost, String tstreet, String tflat) throws SQLException
    {
        List<List<String>> result = new ArrayList<>();

        // select * from uprn_v2.uprn_main where node = 'X5' and post=tpost and street=tstreet and bno=flat
        // flat is number
        String q = "select * from uprn_v2.uprn_main where node = 'X5' and post='"+tpost+"' and street='"+tstreet+"' and bno='"+tflat+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        while (rs.next()) {
            String build = rs.getString("build");
            List<String> row = new ArrayList<>();
            row.add(build);
            result.add(row);
        }

        preparedStatement.close();
        return result;
    }

    public List<List<String>> Drops() throws SQLException
    {
        List<List<String>> result = new ArrayList<>();

        String q = "SELECT * FROM uprn_v2.uprn_dictionary where n1='DROP'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        while (rs.next()) {
            String n2 = rs.getString("n2");
            List<String> row = new ArrayList<>();
            row.add(n2);
            result.add(row);
        }

        preparedStatement.close();
        return result;
    }

    public List<List<String>> X5$part(String part, String tpost, String tstreet, String tbno) throws SQLException
    {
        List<List<String>> result = new ArrayList<>();

        //select * from uprn_v2.uprn_main where build like part% and post = tpost and street=tstreet and bno=tbno
        String q = "select * from uprn_v2.uprn_main where node='X5' and build like '"+part+"%' and post='"+tpost+"' and street='"+tstreet+"' and bno='"+tbno+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        String build = "";
        while (rs.next()) {
            build = rs.getString("build");
            List<String> row = new ArrayList<>();
            row.add(build);
            result.add(row);
        }

        preparedStatement.close();
        return result;
    }

    public List<List<String>> Swaps() throws SQLException
    {
        List<List<String>> result = new ArrayList<>();

        String q = "SELECT * FROM uprn_v2.uprn_dictionary where n1='SWAP'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        while (rs.next()) {
            String n2 = rs.getString("n2");
            String data = rs.getString("data");
            List<String> row = new ArrayList<>();
            row.add(n2);
            row.add(data);
            result.add(row);
        }

        preparedStatement.close();
        return result;
    }

    public List<List<String>> RunUprnMainQuery(String q, String ALG, String matchrec) throws SQLException {
        List<List<String>> result = new ArrayList<>();

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (!rs.next()) {
            return result;
        }

        String uprn = rs.getString("uprn");
        Integer ok = isok(uprn);
        if (ok.equals(0)) {
            return result;
        }

        q = "select distinct `table`, `key` FROM uprn_v2.uprn_main where uprn = '"+uprn+"'";

        System.out.println(q);

        preparedStatement = connection.prepareStatement(q);
        rs = preparedStatement.executeQuery();

        while (rs.next()) {
            String table = rs.getString("table");
            String key = rs.getString("key");
            List<String> row = new ArrayList<>();
            row.add(uprn);
            row.add(table);
            row.add(key);
            row.add(ALG);
            row.add(matchrec);
            result.add(row);
        }

        preparedStatement.close();
        return result;
    }

    public Integer isok(String uprn) throws SQLException {
        if (commercials.equals(1)) return 1;
        return classQuery(uprn);
    }

    public String GETADRABP(String uprn, String table, String key) throws SQLException
    {

        String q = "";

        String post=""; String org=""; String dep=""; String flat=""; String build=""; String bno=""; String depth="";
        String street=""; String deploc=""; String loc=""; String town=""; String ptype=""; String suff="";

        if (table.equals("L")) {
            q = "select * from abp.lpi_records where uprn='" +uprn+ "' and lpi_key='" +key+ "' order by id desc;";
        }

        if (table.equals("D")) {
            q = "select * from abp.dpa_records where uprn='" +uprn+ "' and uduprn = '"+key+"' order by id desc";
            PreparedStatement preparedStatement = connection.prepareStatement(q);
            ResultSet rs = preparedStatement.executeQuery();
            if (rs.next()) {
                post = rs.getString("post_code");
                org = rs.getString("organization_name");
                dep = rs.getString("department_name");
                flat = rs.getString("sub_building_name");
                build = rs.getString("building_name");
                bno = rs.getString("building_number");
                depth = rs.getString("dependent_throughfare");
                street = rs.getString("throughfare");
                deploc = rs.getString("double_dependent_locality");
                loc = rs.getString("dependent_locality");
                town = rs.getString("post_town");
                ptype = rs.getString("postcode_type");
                suff = rs.getString("delivery_point_suffix");
                // ** TO DO copy the code from UPRN1 project to fix up the data using regex checks
            }
        }

        System.out.println(q);
        String d="~";
        String ret = post +d+ org +d+ dep +d+ flat +d+ build +d+ bno +d+ depth +d+ street +d+ deploc +d+ loc +d+ town +d+ ptype +d+ suff;
        return ret;
    }

    public String ClassTerm(String classcode) throws SQLException {
        String classterm = "";

        String q = "select * FROM uprn_v2.uprn_classification where code = '"+classcode+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) {
            classterm = rs.getString("term");
        }

        preparedStatement.close();

        return classterm;
    }

    public String ClassCode(String uprn) throws SQLException {
        String classcode = "";

        String q = "SELECT * FROM uprn_v2.uprn_class where uprn = '"+uprn+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) {
            classcode = rs.getString("code");
        }

        preparedStatement.close();
        return classcode;
    }

    public Integer classQuery(String uprn) throws SQLException {
        String q = "select * from uprn_v2.uprn_class where uprn = '"+uprn+"'";

        System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (!rs.next()) return 1;

        String code = rs.getString("code");
        q = "select * from uprn_v2.uprn_classification where code = '" +code+ "'";

        preparedStatement = connection.prepareStatement(q);
        rs = preparedStatement.executeQuery();

        if (!rs.next()) return 1;

        String res = rs.getString("residential");
        if (res.equals("Y")) return 1;

        preparedStatement.close();
        return 0;
    }

    public void close() throws SQLException {
        connection.close();
    }
}