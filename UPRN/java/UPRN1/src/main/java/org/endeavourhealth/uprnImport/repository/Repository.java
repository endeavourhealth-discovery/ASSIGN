package org.endeavourhealth.uprnImport.repository;

import com.mysql.cj.jdbc.MysqlDataSource;
import com.sun.xml.internal.ws.policy.privateutil.PolicyUtils;
import org.endeavourhealth.uprnImport.routines.RunMySQL;

import java.io.*;
import java.sql.*;
import java.util.*;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.omg.PortableInterceptor.LOCATION_FORWARD;

import static java.lang.Thread.sleep;

import org.mapdb.DB;
import org.mapdb.DBMaker;
import org.mapdb.Serializer;
import java.util.Map;

public class Repository {

    private MysqlDataSource dataSource;
    private Connection connection;
    public String pathToCsv;
    public String mysqluploaddir;
    public String mysqldir;
    public String abpfile;

    private Hashtable<String, String> BLPUHash = new Hashtable<String, String>();
    private Hashtable<String, String> LPSTRHash = new Hashtable<String, String>();

    private Hashtable<String, String> LPIHash = new Hashtable<String, String>();

    private Hashtable<String, String> correctHash = new Hashtable<String, String>();
    private Hashtable<String, String>  hashFlats = new Hashtable<String, String>();
    private Hashtable<String, String>  hashRoads = new Hashtable<String, String>();

    public Repository(Properties properties) throws SQLException {
        init( properties );
    }

    private void init(Properties props) throws SQLException {

        try {

            String url = props.getProperty("url");
            String username = props.getProperty("username");
            String pass = props.getProperty("password");

            pathToCsv = props.getProperty("pathToCsv");
            mysqluploaddir = props.getProperty("mysqluploaddir");
            mysqldir = props.getProperty("mysqldir");
            abpfile = props.getProperty("abpfile");

            dataSource = new MysqlDataSource();

            dataSource.setURL(url);
            dataSource.setUser(username);
            dataSource.setPassword(pass);

            dataSource.setReadOnlyPropagatesToServer(true);

            connection = dataSource.getConnection();

            correctHash = UPRNSHash("CORRECT");
            hashFlats = UPRNSHash("FLAT");
            hashRoads = UPRNSHash("ROAD");

        }
        catch(Exception e)
        {
            System.out.println(e);
        }
    }

    // Levenshtein mumps converted version

    // https://www.geeksforgeeks.org/java-program-to-implement-levenshtein-distance-computing-algorithm/

    static int compute_Levenshtein_distanceDP(String str1,
                                              String str2)
    {

        // A 2-D matrix to store previously calculated
        // answers of subproblems in order
        // to obtain the final

        int[][] dp = new int[str1.length() + 1][str2.length() + 1];

        for (int i = 0; i <= str1.length(); i++)
        {
            for (int j = 0; j <= str2.length(); j++) {

                // If str1 is empty, all characters of
                // str2 are inserted into str1, which is of
                // the only possible method of conversion
                // with minimum operations.
                if (i == 0) {
                    dp[i][j] = j;
                }

                // If str2 is empty, all characters of str1
                // are removed, which is the only possible
                //  method of conversion with minimum
                //  operations.
                else if (j == 0) {
                    dp[i][j] = i;
                }

                else {
                    // find the minimum among three
                    // operations below


                    dp[i][j] = minm_edits(dp[i - 1][j - 1]
                                    + NumOfReplacement(str1.charAt(i - 1),str2.charAt(j - 1)), // replace
                            dp[i - 1][j] + 1, // delete
                            dp[i][j - 1] + 1); // insert
                }
            }
        }

        return dp[str1.length()][str2.length()];
    }

    // check for distinct characters
    // in str1 and str2

    static int NumOfReplacement(char c1, char c2)
    {
        return c1 == c2 ? 0 : 1;
    }

    // receives the count of different
    // operations performed and returns the
    // minimum value among them.

    static int minm_edits(int... nums)
    {

        return Arrays.stream(nums).min().orElse(
                Integer.MAX_VALUE);
    }

    // Driver Code
    public static void main(String args[])
    {

        String s1 = "glomax";
        String s2 = "folmax";

        System.out.println(compute_Levenshtein_distanceDP(s1, s2));
    }

    private String welsh(String string) {

        if (string.isEmpty()) return string;

        string.replace(" yr ","yr");
        string.replace("-yr-","yr");
        string.replace(" y ","y");
        string.replace("-y-","y");

        if (string.substring(0,1).equals("y ")) {string = "y" + string.substring(2,100);}

        if (string.substring(0,1).equals("y-")) {string = "y" + string.substring(2,100);}

        return string;
    }

    private String QueryUPRNS(String node, String word) throws SQLException
    {
        String data = "";

        word = word.replaceAll("'","''");

        String q= "SELECT * FROM uprn.`uprn-s` where n1 = '"+node+"' and n2='" + word + "'";

        //System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) {
            data = rs.getString("data");
        }

        preparedStatement.close();

        return data;
    }

    private String QueryUPRNSHash(Hashtable<String, String> hashTable, String word)
    {
        Enumeration names;

        String data = "";
        names = hashTable.keys();
        while(names.hasMoreElements()) {
            String node = (String) names.nextElement();
            String dataS = hashTable.get(node);

            if (dataS.equals(word)) {
                data = dataS;
                break;
            }
        }
        return data;
    }

    private Hashtable<String, String> UPRNSHash(String node) throws SQLException
    {
        Hashtable<String, String> hashTable =
                new Hashtable<String, String>();

        String data = ""; String n2 = "";

        String q= "SELECT * FROM uprn.`uprn-s` where n1 = '"+node+"'";

        //System.out.println(q);

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        while (rs.next()) {
            data = rs.getString("data");
            n2 = rs.getString("n2");
            hashTable.put(n2,data);
        }

        preparedStatement.close();

        return hashTable;
    }

    private String correct(String text) throws SQLException
    {
        // this method will need changing if the algorithm calls this
        // mumps code references i $d(^UPRNX("X.STR",saint)): correct^UPRNU

        if (text.isEmpty()) return text;

        text = text.replace("lll","ll");

        // if $piece(text," ",1,2)="know as"
        if (Piece(text," ",1,2).equals("known as")) {
            text = Piece(text," ",3,20);
        }

        String[] data = text.split(" ",-1);
        Integer i;
        for (i=0; i < data.length; i++) {
            String word = data[i];
            String correct = QueryUPRNSHash(correctHash, word);
            if (!correct.isEmpty()) {
                data[i] = correct;
            }
        }

        text = "";
        for (i=0; i < data.length; i++) {text = text + data[i] + " ";};
        // remove trailing space
        text = text.trim();


        text.replace(" & "," and ");

        return text;
    }

    public static boolean indexInBound(String[] data, int index){
        return data != null && index >= 0 && index < data.length;
    }

    private String Piece(String str, String del, Integer from, Integer to)
    {
        Integer i;
        String p[] = str.split(del,-1);
        String z = "";

        from = from -1; to = to -1;

        Integer zdel = 0;
        if (to > from) {zdel = 1;}

        for (i = from; i < to; i++) {
            if (indexInBound(p, i)) {
                z = z + p[i];
                if (zdel.equals(1)) {z =z + del;}
            }
        }


        if (zdel.equals((1)) && !z.isEmpty()) {
            // remove delimeter
            z = z.substring(0, z.length()-1);
        }

        return z;
    }

    public void Tests() {
        // piece 0,1 = aa, piece 1,2 = bb, piece 2,3 = cc
        String test = Piece("aa bb cc"," ",1,19);
        System.out.print(test);
    }

    private String flatHash(String text)
    {
        Enumeration names;

        if (text.equals("flat")) {return "";}
        if (text.isEmpty()) {return "";}

        names = hashFlats.keys();
        while(names.hasMoreElements()) {
            String node = (String) names.nextElement();
            String word = hashFlats.get(node);
            if (text.contains(word+" ")) {
                String a = Piece(text, word+" ",1, 1);
                String b = Piece(text, word+" ", 2, 20);
                text = a + b;
            }
        }

        for (;;){
            if (!text.substring(0, 0).equals("0")) {break;}
            text = text.substring(1,49);
        }

        // Flat at end
        String p[] = text.split(" ",-1);
        if (indexInBound(p, 1)) {
            // get last piece
            String flat = p[p.length - 1];
            // flat exist in uprn-s?
            while(names.hasMoreElements()) {
                String node = (String) names.nextElement();
                String word = hashFlats.get(node);
                if (word.equals(text)) {
                    text = word;
                }
            }
        }
        return text;
    }

    private String flat(String text) throws SQLException
    {
        // do I really need to call the database all of the time
        // need to dump into an array list, really

        Integer i;

        if (text.equals("flat")) {return "";}
        if (text.isEmpty()) {return "";}

        // i text?1"no"1" ".e

        // i text?1"flat"1n.n

        // could use a like command?

        String q= "SELECT * FROM uprn.`uprn-s` where n1 = 'FLAT'";
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
            q= "SELECT * FROM uprn.`uprn-s` where n1 = 'FLAT' and n2='"+flat+"'";
            preparedStmt = connection.prepareStatement(q);
            rs = preparedStmt.executeQuery();
            if (rs.next()) {
                text = rs.getString("n2");
            }
        }

        return text;
    }

    public void UPRNSData() throws IOException {
        // creates a csv that's imported into MySQL
        String filename = mysqldir + "uprn-s.csv";
        FileWriter tabWriter = new FileWriter(filename);

        String d = "\t";

        Integer fix = 1; String n = "BESTFIT";

        tabWriter.close();
    }

    public void UPRNS() throws SQLException, IOException {
        // create the file that's going to be be imported into MySQL
        //UPRNSData();
        String q = "load data infile '" + mysqldir + "UPRNS.txt' into table uprn_v2.`uprn_dictionary` FIELDS TERMINATED BY '\\t';";
        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        preparedStatement.close();
    }

    private String getno(String paos,String paosf,String paoe,String paoef)
    {
        // Returnset street number or range

        String numb = "";

        if (!paos.isEmpty()) {
            numb = paos + paosf;
            if (!paoe.isEmpty()) {
                numb = numb + "-" + paoe + paoef;
            }
        }

        return numb;
    }

    private String getflat(String saos,String saosf,String saoe,String saoef,String saot)
    {
        // Returnset flat number or range

        String flat = "";

        if (!saot.isEmpty()) {
            flat = saot;
            if (!saos.isEmpty()) {
                flat = flat + " " + (saos + saosf);
            }
            if (!saoe.isEmpty()) {
                flat = flat + "-" + (saoe + saoef);
            }
            return flat;
        }

        if (!saos.isEmpty()) {
            flat = saos+saosf;
            if (!saoe.isEmpty()) {
                flat = flat + "-" + saoe + saoef;
            }
        }

        return flat;
    }

    private void LoadBLPUandLPSTRIntoMemory() throws SQLException, IOException, InterruptedException
    {

        File f = new File(mysqluploaddir + "1-uprn-export-blpu.csv");
        if(f.exists() && !f.isDirectory()) {
            f.delete();
        }

        f = new File(mysqluploaddir + "1-uprn-export-lpstr.csv");
        if(f.exists() && !f.isDirectory()) {
            f.delete();
        }

        System.out.println("\nExporting BLPU");

        String q = "SELECT * FROM  uprn_v2.`uprn_blpu` INTO OUTFILE '"+ mysqldir + "1-uprn-export-blpu.csv';";
        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        preparedStatement.close();

        System.out.println("Exporting LPSTR");
        // 'C:\\\\ProgramData\\\\MySQL\\\\MySQL Server 5.7\\\\Uploads\\\\1-uprn-export-lpstr.csv';"
        q = "SELECT * FROM  uprn_v2.`uprn_lpstr` INTO OUTFILE '" + mysqldir + "1-uprn-export-lpstr.csv';";
        preparedStatement = connection.prepareStatement(q);
        rs = preparedStatement.executeQuery();
        preparedStatement.close();

        System.out.println("Loading BLPU into memory");

        // smash the output into memory
        String filename = mysqldir + "1-uprn-export-blpu.csv";
        BufferedReader csvReader = new BufferedReader(new FileReader(filename));

        String row = "";
        Integer count = 1;
        while ((row = csvReader.readLine()) != null) {
            String[] data = row.split("\t",-1);
            String uprn = data[1];
            BLPUHash.put(uprn, row);
            if (count % 10000 == 0) {
                System.out.print(".");
                sleep(550);
            }
            count++;
        }
        csvReader.close();

        System.out.println();
        System.out.println("Loading LPSTR into memory");

        // smash the output into memory
        filename = mysqldir + "1-uprn-export-lpstr.csv";
        csvReader = new BufferedReader(new FileReader(filename));

        count = 1;
        while ((row = csvReader.readLine()) != null) {
            String[] data = row.split("\t",-1);
            String usrn= data[1];
            String lang = data[2];
            LPSTRHash.put(usrn+"-"+lang, row);
            if (count % 10000 == 0) {
                System.out.print(".");
            }
            count++;
        }
        csvReader.close();
    }

    public String getBLPU(String uprn) throws SQLException {
        String post = "";
        String q = "select * from uprn_v2.`uprn_blpu` where uprn = '"+uprn+"'";
        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        if (rs.next()) {
            post = rs.getString("post");
        }
        preparedStatement.close();
        return post;
    }

    public String getLPSTR(String lpstr) throws SQLException {
        String[] data = lpstr.split("-",-1);
        String usrn = data[0];
        String lang = data[1];
        String q = "select * from uprn_v2.`uprn_lpstr` where usrn='"+usrn+"' and lang ='"+lang+"'";

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        String name = ""; String locality = ""; String town = ""; String ret = "";
        if (rs.next()) {
            //System.out.println(rs.getString("name"));
            name = rs.getString("name");
            //System.out.println(rs.getString("locality"));
            locality = rs.getString("locality");
            //System.out.println(rs.getString("town"));
            town = rs.getString("town");
            ret = name+"~"+locality+"~"+town;
        }
        preparedStatement.close();
        return ret;
    }

    // GETLPI^UPRNU
    //
    public List<List<String>> GETLPI(String saos, String saosf, String saoe, String saoef, String saot, String paos, String paosf, String paoe, String paoef, String paot, String lpstr, String uprn) throws SQLException
    {
        String  lpdes = ""; String lploc = ""; String lptown = ""; String lpname = ""; String lpadmin = "";

        /*
        String ret = getLPSTR(lpstr);
        if (!ret.isEmpty()) {
            String[] data = ret.split("~",-1);
            lpdes = data[0];
            lploc = data[1];
            lptown = data[2];
        }
         */

        if (LPSTRHash.containsKey(lpstr)) {
            String zrow = LPSTRHash.get(lpstr);
            String[] data = zrow.split("\t",-1);
            lpdes = data[3];
            lploc = data[4];
            lptown = data[6];

            //
            lpname = data[3];
            lpadmin = data[5];
        }

        List<List<String>> apadr = new ArrayList<>();
        List<String> row = new ArrayList<>();

        String flat = getflat(saos,saosf,saoe,saoef,saot); // 0
        row.add(flat);

        String building = paot;
        row.add(building); // 1
        String number = getno(paos,paosf,paoe,paoef);
        row.add(number); // 2

        String post = "";

        // post = getBLPU(uprn);

        if (BLPUHash.containsKey(uprn)) {
            String zrow = BLPUHash.get(uprn);
            String[] data = zrow.split("\t", -1);
            post = data[3];
        }

        String street = lpdes;
        row.add(street); // 3

        String locality = lploc;
        row.add(locality); // 4

        String town = lptown;
        row.add(town); // 5

        row.add(post); // 6

        String apaddress = flat + " " + building + " " + number + " " + street + " " + locality + " " + post;
        row.add(apaddress); // 7

        row.add(lpname); // 8
        row.add(lpadmin); // 9

        apadr.add(row);
        return apadr;
    }

    public void IMPLPI2(String filename) throws SQLException, IOException, InterruptedException {

        // use SQL instead (see if it runs faster after indexinglpstr and blpu)
        LoadBLPUandLPSTRIntoMemory();

        //String filename = pathToCsv + "ID24_LPI_Records.csv";

        BufferedReader csvReader = new BufferedReader(new FileReader(filename));

        String row = ""; Integer ft = 1;
        String d = "\t";

        String tFile = mysqluploaddir + "1-ID24_LPI_Records.csv.txt";
        FileWriter tabWriter = new FileWriter(tFile);

        System.out.println("Importing ID24_LPI_Records.csv");

        // use that MySQL function to get the last index in the file (don't use MAX)

        Integer count = 1;

        String q = "SELECT max(id) FROM uprn_v2.`temp_import_u`";
        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        if (rs.next()) {
            count = rs.getInt("max(id)") + 1;
        }
        preparedStatement.close();

        Hashtable<String, String> hashtable =
                new Hashtable<String, String>();

        while ((row = csvReader.readLine()) != null) {
            // take the ft stuff out if running split file
            if (ft.equals(1)) {
                ft = 0;
                continue;
            }

            row = row.replace("\"","");
            row = row.toLowerCase();

            String[] data = row.split(",",-1);
            String change = data[1];
            String uprn = data[3];
            String key = data[4];

            // sao = secondary adddressable object
            // pao = primary addressable object
            String saos = data[11]; // sao_start_number (1)
            String saosf = data[12]; // sao_start_suffix (A)
            String saoe = data[13]; // sao_end_number (1)
            String saoef = data[14]; // sao_end_suffix (B)
            String saot = data[15]; // sao_text (UNITS)
            String status = data[6]; // logical_status
            String end = data[8]; // end_date
            String paos = data[16]; // pao_start_number
            String paosf = data[17]; // pao_start_suffix
            String paoe = data[18]; // pao_end_number
            String paoef = data[19]; // pao_end_suffix
            String paot = data[20]; // pao_text
            String str = data[21] + "-" + data[5]; // usrn+"-"+language

            String level = data[24]; // level (ground floor)

            String org = ""; // intentionally set to null - organisation is in DPA data

            // should always return 1 row
            List<List<String>> dpadd = GETLPI(saos, saosf, saoe, saoef, saot, paos, paosf, paoe, paoef, paot, str, uprn);

            List<String> apaddress = dpadd.get(0);

            String flat = apaddress.get(0);
            String build = apaddress.get(1).trim();

            String bno = correct(apaddress.get(2));

            String depth = ""; // set to null in mumps code (see IMPLPI^UPRN1)
            String street =apaddress.get(3).trim();
            String loc = apaddress.get(4).trim(); // locality
            String town = apaddress.get(5);
            String post = apaddress.get(6);

            String name = apaddress.get(8);
            String admin = apaddress.get(9);

            street = correct(street);
            build = correct(build);

            flat = correct(flat);
            flat = flatHash(flat);

            loc = correct(loc);

            String dep = "";
            String ptype = "";
            String deploc = ""; // interntionally set to null in m code (see GETLPI^UPRNU)

            // missing level (needs adding to schema)
            String tabbed = "L" +d+ uprn +d+ key +d; // +flat+d+build+d+bno+d+depth+d+street+d+deploc+d+loc+d+town+d+post+d+org+d+dep+d+ptype+d;

            // don't need to lowercase the var because the whole record gets lower case'd?
            // see mumps code

            flat = welsh(flat);
            build = welsh(build);
            depth = welsh(depth);
            street = welsh(street);
            deploc = welsh(deploc);
            loc = welsh(loc);

            tabbed = tabbed+flat +d+ build +d+ bno +d+ depth +d+ street +d+ deploc +d+ loc +d+ town +d+ post +d+ org +d+ dep +d+ ptype +d+ admin +d+ name;

            if (count % 10000 == 0) {
                System.out.print(".");
            }

            //hashtable.put(uprn+"~"+key,tabbed);

            tabWriter.append(count + d + tabbed);
            tabWriter.append("\n");

            count++;

        }

        csvReader.close();

        BLPUHash.clear();
        LPSTRHash.clear();

        tabWriter.flush();
        tabWriter.close();

        filename = mysqluploaddir + "1-ID24_LPI_Records.csv.txt";
        csvReader = new BufferedReader(new FileReader(filename));

        tFile = mysqluploaddir + "2-ID24_LPI_Records.csv.txt";
        tabWriter = new FileWriter(tFile);

        System.out.println("\nFiling LPI");

        count = 1;
        while ((row = csvReader.readLine()) != null) {

            tabWriter.append(row);
            tabWriter.append("\n");

            if (count % 10000 == 0) {
                tabWriter.flush();
                tabWriter.close();

                System.out.print(".");

                q = "load data infile '" + mysqldir + "2-ID24_LPI_Records.csv.txt' into table uprn_v2.`temp_import_u` FIELDS TERMINATED BY '\\t';";
                preparedStatement = connection.prepareStatement(q);
                rs = preparedStatement.executeQuery();
                preparedStatement.close();

                tabWriter = new FileWriter(tFile);

                System.out.print("x");
            }

            count++;
        }

        csvReader.close();

        tabWriter.flush();
        tabWriter.close();

        q = "load data infile '" + mysqldir + "2-ID24_LPI_Records.csv.txt' into table uprn_v2.`temp_import_u` FIELDS TERMINATED BY '\\t';";
        preparedStatement = connection.prepareStatement(q);
        rs = preparedStatement.executeQuery();
        preparedStatement.close();

        System.out.print("\n");
    }

    public void TurnFileIntoTabDelimeted(String filename, String newFile, String epoch, String table) throws IOException, SQLException
    {
        BufferedReader reader = new BufferedReader(
                new InputStreamReader(new FileInputStream(filename), "UTF-8"));
        CSVParser csvParser = new CSVParser(reader, CSVFormat.DEFAULT);

        String tFile = mysqluploaddir + newFile;
        FileWriter tabWriter = new FileWriter(tFile);

        Integer ft = 1;
        String d = "\t";

        Integer count = 1;

        for (CSVRecord csvRecord : csvParser) {
            if (ft.equals(1)) {
                ft = 0;
                continue;
            }

            Integer z = csvRecord.size();
            Integer i;

            String tabbed = count+d;
            for ( i=0; i<z; i++ ) {
                tabbed = tabbed+csvRecord.get(i)+d;
            }

            tabbed = tabbed+epoch;

            tabWriter.append(tabbed);
            tabWriter.append("\n");

            if ( count % 10000 == 0 ) {
                // consume the data - and start again
                tabWriter.flush();
                tabWriter.close();

                System.out.print(".");

                String q = "load data infile '" + tFile + "' into table " + table + " FIELDS TERMINATED BY '\\t';";

                PreparedStatement preparedStatement = connection.prepareStatement(q);
                ResultSet rs = preparedStatement.executeQuery();
                preparedStatement.close();

                tabWriter = new FileWriter(tFile);

                System.out.print("x");
            }
            count++;
        }

        csvParser.close();

        tabWriter.flush();
        tabWriter.close();

        String q = "load data infile '" + tFile + "' into table " + table + " FIELDS TERMINATED BY '\\t';";

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        preparedStatement.close();
    }

    public void AddEpochToExistingFiles()
    {

    }

    public void IMPABP() throws SQLException, IOException {

        System.out.println("Importing ABP data");

        BufferedReader csvReader = new BufferedReader(new FileReader(abpfile));

        String tFile = mysqluploaddir + "1-ABP.txt";
        FileWriter tabWriter = new FileWriter(tFile);

        Integer count = 1; String row;

        /*
        String q = "SELECT max(id) FROM abp.`baseline`";
        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        if (rs.next()) {
            count = rs.getInt("max(id)") + 1;
        }
        preparedStatement.close();
         */

        String q; PreparedStatement preparedStatement; ResultSet rs;

        while ((row = csvReader.readLine()) != null) {

            tabWriter.append(row);
            tabWriter.append("\n");

            if (count % 10000 == 0) {
                tabWriter.flush();
                tabWriter.close();

                System.out.print(".");

                q = "load data infile '" + mysqldir + "1-ABP.txt' into table abp.`baseline` FIELDS TERMINATED BY '\\t';";
                preparedStatement = connection.prepareStatement(q);
                rs = preparedStatement.executeQuery();
                preparedStatement.close();

                System.out.print("x");

                tabWriter = new FileWriter(tFile);
            }

            count++;
        }

        tabWriter.flush();
        tabWriter.close();

        q = "load data infile '" + mysqldir + "1-ABP.txt' into table abp.`baseline` FIELDS TERMINATED BY '\\t';";
        preparedStatement = connection.prepareStatement(q);
        rs = preparedStatement.executeQuery();
        preparedStatement.close();
    }

    public void IMPDPA2() throws SQLException, IOException {

        //Tests();

        //Integer out = 1;
        //if (out.equals(1)) {return;}

        System.out.println("\nImporting ID28_DPA_Records.csv");

        Enumeration names;

        Hashtable<String, String> hashtable =
                new Hashtable<String, String>();


        String filename = pathToCsv + "ID28_DPA_Records.csv";

        BufferedReader csvReader = new BufferedReader(new FileReader(filename));

        String row = "";

        Integer ft = 1; Integer fileCount=2;

        String d = "\t";

        String tFile = mysqluploaddir + "1-ID28_DPA_Records.csv.txt";
        FileWriter tabWriter = new FileWriter(tFile);

        Integer count = 1;

        while ((row = csvReader.readLine()) != null) {
            if (ft.equals(1)) {ft=0; continue;}

            row = row.replace("\"","");
            row = row.replace("'","");

            //row = row.replace(", ,",",,");
            //row = row.replace(".'","");

            String[] data = row.split(",",-1);
            String uprn = data[3];
            String post = data[15]; // postcode
            String key = data[4];
            String change = data[1];
            String org = data[5]; // organization
            String dep = data[6]; // department_name
            String flat = data[7]; // sub_building_name or flat
            String build = data[8]; // building_name
            String bno = data[9]; // building number
            String depth = data[10]; // dependent_throughfare
            String street = data[11]; // throughfare or street
            String deploc = data[12]; // double_dependent_locality
            String loc = data[13]; // dependent_locality
            String town = data[14]; // post_town
            String ptype = data[16]; // postcode_type
            String suff = data[17]; // deliver_point_suffix

            // o* fields
            String tabbed = "D"+d+uprn+d+key+d; //+flat+d+build+d+bno+d+depth+d+street+d+deploc+d+loc+d+town+d+post+d+org+d+dep+d+ptype+d;

            // lower case the fields
            flat = flat.toLowerCase();
            build = build.toLowerCase();
            bno = bno.toLowerCase();
            depth = depth.toLowerCase();
            street = street.toLowerCase();
            deploc = deploc.toLowerCase();
            loc = loc.toLowerCase();
            town = town.toLowerCase();
            post = post.replace(" ","").toLowerCase();
            org = org.toLowerCase();
            dep = dep.toLowerCase();
            ptype = ptype.toLowerCase();

            flat = welsh(flat);
            build = welsh(build);
            depth = welsh(depth);
            street = welsh(street);
            deploc = welsh(deploc);
            loc = welsh(loc);

            street = correct(street);
            bno = correct(bno);
            build = correct(build);
            loc = correct(loc);

            // flat
            flat = flatHash(flat);

            flat = correct(flat);
            depth = correct(depth);
            deploc = correct(deploc);

            String admin = "";
            String name = "";

            tabbed = tabbed+flat +d+ build +d+ bno +d+ depth +d+ street +d+ deploc +d+ loc +d+ town +d+ post +d+ org +d+ dep +d+ ptype +d+ admin +d+ name;

            if (count % 10000 == 0) {
                System.out.print(".");
            }

            hashtable.put(uprn+"~"+key,tabbed);

            count++;
        }

        csvReader.close();

        names = hashtable.keys();

        count = 1;

        String q = "SELECT max(id) FROM uprn_v2.`temp_import_u`";
        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        if (rs.next()) {
            count = rs.getInt("max(id)") + 1;
        }
        preparedStatement.close();

        System.out.println("\nImporting ID28_DPA_Records.csv");

        while(names.hasMoreElements()) {
            String uprnKey = (String) names.nextElement();
            String tabbed = hashtable.get(uprnKey);

            tabWriter.append(count + d + tabbed);
            tabWriter.append("\n");

            if (count % 10000 == 0) {
                tabWriter.flush();
                tabWriter.close();

                System.out.print(".");

                q = "load data infile '" + mysqldir + "1-ID28_DPA_Records.csv.txt' into table uprn_v2.`temp_import_u` FIELDS TERMINATED BY '\\t';";
                preparedStatement = connection.prepareStatement(q);
                rs = preparedStatement.executeQuery();
                preparedStatement.close();

                System.out.print("x");

                tabWriter = new FileWriter(tFile);
            }

            count++;
        }

        tabWriter.flush();
        tabWriter.close();

        q = "load data infile '" + mysqldir + "1-ID28_DPA_Records.csv.txt' into table uprn_v2.`temp_import_u` FIELDS TERMINATED BY '\\t';";
        preparedStatement = connection.prepareStatement(q);
        rs = preparedStatement.executeQuery();
        preparedStatement.close();

    }

    // reads BPL to populate uprn-upc table with parent data
    public void IMPUPC() throws SQLException, IOException {
        Enumeration names;

        Hashtable<String, String> hashParent =
                new Hashtable<String, String>();

        String filename = pathToCsv + "ID21_BLPU_Records.csv";
        BufferedReader reader = new BufferedReader(
                new InputStreamReader(new FileInputStream(filename), "UTF-8"));
        CSVParser csvParser = new CSVParser(reader, CSVFormat.DEFAULT);

        Integer ft = 1;
        String d = "\t";

        for (CSVRecord csvRecord : csvParser) {
            if (ft.equals(1)) {
                ft = 0;
                continue;
            }

            String uprn = csvRecord.get(3);
            String parent = csvRecord.get(7).toLowerCase();

            if (!parent.isEmpty()) {
                hashParent.put(parent + "~" + uprn, "");
            }
        }

        csvParser.close();

        String parentcsv = mysqldir+"1-blpu-parents.csv.txt";

        FileWriter tabParentWriter = new FileWriter(parentcsv);

        names = hashParent.keys();

        Integer count = 1;

        while(names.hasMoreElements()) {
            String node = (String) names.nextElement();
            String data[] = node.split("~",-1);
            String parent = data[0]; String uprn = data[1];

            tabParentWriter.append(count + d + parent + d + uprn);
            tabParentWriter.append("\n");

            if (count % 200000 == 0) {
                tabParentWriter.flush();
                tabParentWriter.close();

                String q = "load data infile '"+mysqldir+"1-blpu-parents.csv.txt' into table uprn.`uprn-upc` FIELDS TERMINATED BY '\\t';";
                PreparedStatement preparedStatement = connection.prepareStatement(q);
                ResultSet rs = preparedStatement.executeQuery();
                preparedStatement.close();

                tabParentWriter = new FileWriter(parentcsv);
                System.out.println(count);
            }

            count++;
        }

        tabParentWriter.flush();
        tabParentWriter.close();

        String q = "load data infile '"+mysqldir+"1-blpu-parents.csv.txt' into table uprn.`uprn-upc` FIELDS TERMINATED BY '\\t';";
        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        preparedStatement.close();
    }

    public void IMPBPL2() throws SQLException, IOException {

        Enumeration names;

        System.out.println("Importing ID21_BLPU_Records.csv");

        Hashtable<String, String> hashtable =
                new Hashtable<String, String>();

        String filename = pathToCsv + "ID21_BLPU_Records.csv";
        BufferedReader reader = new BufferedReader(
                new InputStreamReader(new FileInputStream(filename), "UTF-8"));
        CSVParser csvParser = new CSVParser(reader, CSVFormat.DEFAULT);

        Integer ft = 1; Integer count = 1;
        String d = "\t";

        for (CSVRecord csvRecord : csvParser) {
            if (ft.equals(1)) {
                ft = 0;
                continue;
            }

            String post = csvRecord.get(20).replace(" ","").toLowerCase();
            String uprn = csvRecord.get(3);
            String status = csvRecord.get(4).toLowerCase();
            String change = csvRecord.get(1).toLowerCase();
            String bpstat = csvRecord.get(5).toLowerCase();
            String insdate = csvRecord.get(15).toLowerCase();
            String update = csvRecord.get(17).toLowerCase();
            String parent = csvRecord.get(7).toLowerCase();
            String coord1 = csvRecord.get(8)+","+csvRecord.get(9)+","+csvRecord.get(10)+","+csvRecord.get(11)+","+csvRecord.get(12);
            String local = csvRecord.get(13).toLowerCase();
            String adpost = csvRecord.get(19).toLowerCase();

            String tabbed = uprn+d+adpost+d+post+d+status+d+bpstat+d+insdate+d+update+d+coord1+d+local;

            if (count % 10000 == 0) {
                System.out.print(".");
            }

            hashtable.put(uprn, tabbed);

            count++;
        }

        csvParser.close();;

        filename = mysqluploaddir+"1-ID21_BLPU_Records.csv.txt";

        FileWriter tabWriter = new FileWriter(filename);

        names = hashtable.keys();

        System.out.println("\nImporting ID21_BLPU_Records.csv");

        count = 1;

        while(names.hasMoreElements()) {
            String uprn = (String) names.nextElement();
            String tabbed =  hashtable.get(uprn);

            tabWriter.append(count + d + tabbed);
            tabWriter.append("\n");

            if (count % 10000 == 0) {
                tabWriter.flush();
                tabWriter.close();

                System.out.print(".");

                String q = "load data infile '"+mysqldir+"1-ID21_BLPU_Records.csv.txt' into table uprn_v2.`uprn_blpu` FIELDS TERMINATED BY '\\t';";
                PreparedStatement preparedStatement = connection.prepareStatement(q);
                ResultSet rs = preparedStatement.executeQuery();
                preparedStatement.close();

                System.out.print("x");

                tabWriter = new FileWriter(filename);
            }

            count++;
        }

        tabWriter.flush();
        tabWriter.close();

        String q = "load data infile '"+mysqldir+"1-ID21_BLPU_Records.csv.txt' into table uprn_v2.`uprn_blpu` FIELDS TERMINATED BY '\\t';";
        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        preparedStatement.close();
    }

    private String plural(String text)
    {
        String[] data = text.split(" ",-1);
        Integer i; String r = ""; Integer PLURAL;
        PLURAL = 0;
        for (i=0; i < data.length; i++) {
            String word = data[i];
            Integer l = word.length();
            if (word.substring(l, l).equals("s")) {
                word = word.substring(0, word.length() - 1);
                r = r + word + " ";
            } else {
                r = r + word + " ";
            }
            PLURAL = 1;
        }

        if (PLURAL.equals(1)) { r = r.substring(0, r.length()-1); }
        if (r.isEmpty()) { r = text;}

        return r;
    }

    private void indexstr(String index, String term, Integer strno) throws SQLException
    {
        // might change this into a hash table - but for now use inserts
        String q = "SELECT * from uprn.`uprn-x.` where `index`='X."+index+"' and term='"+term+"'";
        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        if (!rs.next()) {

            q = "insert into uprn.`uprn-x.` (`index`, term, strno) values(?,?,?)";
            PreparedStatement preparedStmt = connection.prepareStatement(q);
            preparedStmt.setString(1,"X."+index);
            preparedStmt.setString(2,term);
            preparedStmt.setString(3,strno.toString());
            preparedStmt.execute();
            preparedStmt.close();

        }

        if (rs.next()) {
            strno = Integer.parseInt(rs.getString("strno"));
        }

        preparedStatement.close();

        Integer i;
        String[] data = term.split(" ",-1);
        for (i=0; i < data.length; i++) {
            String word = data[i];
            if (word.isEmpty()) {continue;}

            String zword = QueryUPRNSHash(correctHash, word);
            if (!zword.isEmpty()) {word=zword;}

            zword = QueryUPRNSHash(hashRoads, word);
            if (!zword.isEmpty()) {word=zword;}

            q = "SELECT * from uprn_v2.`uprn_x.` where `index`='X."+index+"' and term='"+word+"'";

            preparedStatement = connection.prepareStatement(q);
            rs = preparedStatement.executeQuery();
            if (!rs.next()) {
                q = "insert into uprn_v2.`uprn_x.` (`index`, strno, word) values (?,?,?);";
                PreparedStatement preparedStmt = connection.prepareStatement(q);
                preparedStmt.setString(1, index);
                preparedStmt.setString(2, strno.toString());
                preparedStmt.setString(3, word);
                preparedStmt.execute();
                preparedStmt.close();
            }
        }
    }

    public void Smash() throws IOException
    {
        String filename = "C:\\ProgramData\\MySQL\\MySQL Server 5.7\\Uploads\\idx-indmain.txt";
        BufferedReader csvReader = new BufferedReader(new FileReader(filename));

        String row = "";
        Integer count = 1;

        while ((row = csvReader.readLine()) != null) {
            if (count % 1000 == 0) {

            }
        }
        csvReader.close();
    }

    // COVERING INDEXES!
    public void UPRNINDMAIN() throws SQLException, IOException {
        File f = new File(mysqluploaddir+"1-uprn-export.csv");

        if(f.exists() && !f.isDirectory()) {
            f.delete();
        }

        String q = "SELECT flat, build, bno, depth, street, deploc, loc, town, post, org, dep, ptype, `table`, uprn, `key`, name, admin  FROM  uprn_v2.`temp_import_u` INTO OUTFILE '"+mysqluploaddir+"1-uprn-export.csv';";

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        preparedStatement.close();

        String filename = mysqluploaddir+"1-uprn-export.csv";

        BufferedReader csvReader = new BufferedReader(new FileReader(filename));

        String idxfile = mysqluploaddir+"idx-indmain.txt";

        FileWriter tabWriter = new FileWriter(idxfile);

        String row = "";
        String d = "\t";

        Integer count = 1; Integer strno = 0;

        String x_tabbed = "";

        while ((row = csvReader.readLine()) != null) {
            String[] ss = row.split("\t", -1);
            String flat = ss[0];
            String build = ss[1];
            String bno = ss[2];
            String depth = ss[3];
            String street = ss[4];
            String deploc = ss[5];
            String loc = ss[6];
            String town = ss[7];
            String post = ss[8];
            String org = ss[9];
            String dep = ss[10];
            String ptype = ss[11];
            String table = ss[12];
            String uprn = ss[13];
            String key = ss[14];
            String name = ss[15];
            String admin = ss[16];

            // check if town exists?
            // if not exists then add to another export file

            String[] words = street.trim().split("\\s+",-1);
            if (words.length>6) continue;

            words = build.trim().split("\\s+",-1);
            if (words.length>6) continue;

            String pstreet = plural(street);
            String pbuild = plural(build);
            String pdepth = plural(depth);

            Integer same = 0;

            if (pstreet.equals(street) && pbuild.equals(build) && pdepth.equals(depth)) {same = 1;}

            String indrec = post + " " + flat + " " + build + " " + bno + " " + depth + " " + street + " " + deploc + " " + loc;

            indrec = indrec.replaceAll("  "," ");
            indrec = indrec.trim();

            // String x_tabbed = count+d+indrec+d+uprn+d+table+d+key;
            String xbno=""; String xbuild=""; String xflat=""; String xstreet="";
            String xindrec = "";

            String xname = ""; String xlocality = ""; String xadmin = ""; String xtown = "";
            String xdeploc = ""; String xloc = ""; String xorg = "";

            x_tabbed = count +d+ "X" +d+ uprn +d+ table +d+ key +d+ post +d+ indrec +d+ bno +d+ build +d+ flat +d+ street +d+ xname +d+ loc +d+ xadmin +d+ town;
            tabWriter.append(x_tabbed+"\n");
            count++;

            if (same.equals(0)) {
                indrec = post + " " + flat + " " + pbuild + " " + bno + " " + pdepth + " " + pstreet + " " + deploc + " " + loc;
                indrec = indrec.replaceAll("  "," ");
                indrec = indrec.trim();
                //x_tabbed = count+d+indrec+d+uprn+d+table+d+key;
                x_tabbed = count +d+ "X" +d+ uprn +d+ table +d+ key +d+ post +d+ indrec +d+ xbno +d+ xbuild +d+ xflat +d+ xstreet;
                //count++;
                //tabWriter.append(x_tabbed+"\n");
            }

            String x5_tabbed = "";
            if (!deploc.isEmpty()) {
                //x5_tabbed = count+d+post + d + street+" "+deploc+d+bno+d+build+d+flat+d+uprn+d+table+d+key;
                x_tabbed = count+d+"X5"+d+uprn+d+table+d+key+d+post+d+street+" "+deploc+d+xindrec+d+bno+d+build+d+flat+d+xstreet;
                //tabWriter.append(x_tabbed+"\n");
                //count++;
            }

            if (!depth.isEmpty()) {
                //x5_tabbed = post + d + depth+" "+street+d+bno+d+build+d+flat+d+uprn+d+table+d+key;
                x_tabbed = count+d+"X5"+d+uprn+d+table+d+key+d+post+d+ depth+" "+street+d+xindrec+d+bno+d+build+flat+d+xstreet;
                //tabWriter.append(x_tabbed+"\n");
                //count++;

                // table def: id,node,uprn,table,key,post,n1,indrec,bno,build,flat,street

                //x5_tabbed = post+d+street+d+bno+d+depth+d+flat+" "+build+d+uprn+d+table+d+key;
                //x_tabbed = count+d+"X5"+uprn+d+table+d+key+post+d+flat+" "+build+d+xindrec+d+bno+d+build+d+flat+street;
                //tabWriter.append(x_tabbed+"\n");
                //count++;

                if (same.equals(0)) {
                    //x5_tabbed = count+d+post+d+street+d+bno+d+pdepth+d+flat+" "+pbuild+d+uprn+table+key;
                    //x_tabbed = count+d+"X5"+d+uprn+d+table+d+key+d+post+d+flat+" "+pbuild+d+bno+d+pdepth+d+xflat+d+pstreet;
                    //tabWriter.append(x_tabbed);
                    //count++;
                }
            }

            //x5_tabbed = post+d+street+d+bno+d+build+d+flat+d+uprn+d+table+d+key;
            //x_tabbed = count+d+"X5"+uprn+d+table+d+key+d+post+d+xn1+d+xindrec+d+bno+d+build+d+flat+d+street;
            //tabWriter.append(x_tabbed);
            //count++;

            if (same.equals(0)) {
                x5_tabbed = count+d+pstreet+d+bno+d+pbuild+d+flat+d+uprn+d+table+d+key;
            }

            String x3_tabbed = "";
            if (!depth.isEmpty()) {
                x3_tabbed = count+depth+d+bno+d+post+d+uprn+d+table+d+key;
                x3_tabbed = count+pdepth+d+bno+d+post+d+uprn+d+table+d+key;
                strno = strno++;
                //indexstr("STR", depth, strno);
                if (!pdepth.equals(depth)) {
                    strno++;
                    //indexstr("STR",pdepth, strno);
                }
            }

            if (!deploc.isEmpty() && street.isEmpty()) {
                x5_tabbed = count+d+post+d+deploc+d+bno+d+build+d+flat+d+uprn+d+table+d+key;
            }

            if (!depth.isEmpty() && street.isEmpty()) {
                x5_tabbed = depth+d+bno+d+build+d+flat+d+uprn+d+table+d+key;
                if (same.equals(0)) {
                    x5_tabbed = count+d+pdepth+d+bno+d+pbuild+d+flat+d+uprn+d+table+d+key;
                }
            }

            if (!street.isEmpty()) {
                x3_tabbed = count+d+street+d+bno+d+post+d+uprn+d+table+d+key;
                if (same.equals(0)) {
                    x3_tabbed = count+d+pstreet+d+bno+d+post+d+uprn+d+table+d+key;
                }
                x3_tabbed = count+d+street.replace(" ","")+d+bno+d+post+d+uprn+d+table+d+key;
                if (!depth.isEmpty()) {
                    x3_tabbed = count+d+depth+" "+street+d+bno+d+post+d+uprn+d+table+d+key;
                    if (same.equals(0)) { x3_tabbed = count+d+pdepth+" "+street+d+bno+d+post+d+uprn+d+table+d+key;}
                }
                strno++;
                //indexstr("STR",street,strno);
                //if (!pstreet.equals(street)) {strno++; indexstr("STR",pstreet,strno);}
            }

            if (!build.isEmpty()) {
                x3_tabbed = count+d+build+d+flat+d+post+d+uprn+d+table+d+key;
                if (same.equals(0)) {
                    x3_tabbed = count+d+pbuild+flat+d+post+d+uprn+d+table+d+key;
                }
                //strno++; indexstr("BLD",build,strno);
                //if (!pbuild.equals(build)) {strno++; indexstr("BLD",pbuild,strno);}
            }

            if (!build.isEmpty() && !flat.isEmpty() && !street.isEmpty()) {
                String x2_tabbed = count+d+build+d+street+d+flat+d+post+d+bno+d+uprn+d+table+d+key;
            }

            if (!flat.isEmpty() && !bno.isEmpty() && !street.isEmpty() & !build.isEmpty()) {
                String x4_tabbed = count+d+post+d+street+d+bno+d+flat+d+build+uprn+table+key;
            }

            if (build.isEmpty() && !org.isEmpty()) {
                x5_tabbed = count+d+post+d+street+d+bno+d+org+d+flat+d+uprn+d+table+d+key;
                if (same.equals(0)) {
                    x5_tabbed = count+d+post+d+pstreet+d+bno+d+org+d+flat+d+uprn+d+table+d+key;
                }
                if (!flat.isEmpty()) {
                    x3_tabbed = count+d+org+d+flat+d+post+d+uprn+d+table+d+key;
                    //strno++; indexstr("BLD",org,strno);
                }
            }

            if (!street.isEmpty() && !bno.isEmpty() && !build.isEmpty() && !flat.isEmpty()) {
                String x5a_tabbed = count+d+post+d+street+d+build+d+flat+d+bno+d+uprn+d+table+d+key;
                if (same.equals(0)) {
                    x5a_tabbed = count+d+post+d+pstreet+d+pbuild+d+flat+d+bno+d+uprn+d+table+d+key;
                }
            }

            if (!pstreet.equals(street) || !pbuild.equals(build)) {
                if (!deploc.isEmpty()) {
                    x5_tabbed = count+d+post+d+pstreet+" "+deploc+d+bno+d+pbuild+d+flat+d+uprn+d+table+d+key;
                }
                if (!pdepth.isEmpty()) {
                    x5_tabbed = count+d+post+d+pdepth+" "+pstreet+d+bno+d+pbuild+d+flat+d+uprn+d+table+d+key;
                }
            }

            if (count % 1000 == 0) {
                tabWriter.flush();
                tabWriter.close();
                System.out.print(".");

                q = "load data infile '" + mysqldir + "idx-indmain.txt' into table uprn_v2.`uprn_main` FIELDS TERMINATED BY '\\t';";
                preparedStatement = connection.prepareStatement(q);
                rs = preparedStatement.executeQuery();
                preparedStatement.close();

                tabWriter = new FileWriter(idxfile);

                System.out.print("x");

            }

        }
        tabWriter.flush();
        tabWriter.close();

        csvReader.close();

        q = "load data infile '" + mysqldir + "idx-indmain.txt' into table uprn_v2.`uprn_main` FIELDS TERMINATED BY '\\t';";
        preparedStatement = connection.prepareStatement(q);
        rs = preparedStatement.executeQuery();
        preparedStatement.close();

    }

    public void IMPSTR2() throws SQLException, IOException {

        Enumeration names;

        System.out.println("\nImporting ID15_StreetDesc_Records.csv");

        Hashtable<String, String> hashtable =
                new Hashtable<String, String>();

        String filename = pathToCsv + "ID15_StreetDesc_Records.csv";
        BufferedReader reader = new BufferedReader(
                new InputStreamReader(new FileInputStream(filename), "UTF-8"));
        CSVParser csvParser = new CSVParser(reader, CSVFormat.DEFAULT);

        Integer ft = 1; Integer count = 1;
        String d = "\t";

        for (CSVRecord csvRecord : csvParser) {
            if (ft.equals(1)) {ft=0; continue;}

            String change = csvRecord.get(1).toLowerCase();
            String usrn = csvRecord.get(3).toLowerCase();
            String name = csvRecord.get(4).toLowerCase();
            String locality = csvRecord.get(5).toLowerCase();
            String town = csvRecord.get(6).toLowerCase();
            String admin = csvRecord.get(7).toLowerCase();
            String lang = csvRecord.get(8).toLowerCase();

            hashtable.put(usrn+"-"+lang,usrn+d+lang+d+name+d+locality+d+admin+d+town);

            if (count % 10000 == 0) {
                System.out.print(".");
            }

            count++;
        }

        filename = mysqluploaddir+"1-ID15_StreetDesc_Records.csv.txt";

        FileWriter tabWriter = new FileWriter(filename);

        names = hashtable.keys();

        count = 1;

        while(names.hasMoreElements()) {
            String usrn = (String) names.nextElement();
            String tabbed =  hashtable.get(usrn);

            tabWriter.append(count + d + tabbed);
            tabWriter.append("\n");

            count++;
        }

        tabWriter.flush();
        tabWriter.close();

        System.out.println("\nImporting ID15_StreetDesc_Records.csv");

        String q = "load data infile '"+mysqldir+"1-ID15_StreetDesc_Records.csv.txt' into table uprn_v2.`uprn_lpstr` FIELDS TERMINATED BY '\\t';";
        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        preparedStatement.close();
    }

    public void IMPCLASS2() throws SQLException, IOException {

        Enumeration names;
        String key;

        System.out.println("Importing ID32_Class_Records.csv");

        Hashtable<String, String> hashtable =
                new Hashtable<String, String>();

        String filename = pathToCsv + "ID32_Class_Records.csv";
        BufferedReader reader = new BufferedReader(
                new InputStreamReader(new FileInputStream(filename), "UTF-8"));
        CSVParser csvParser = new CSVParser(reader, CSVFormat.DEFAULT);

        Integer ft = 1; Integer count = 1; Integer fileCount=2;
        String d = "\t";

        for (CSVRecord csvRecord : csvParser) {
            String scheme = csvRecord.get(6);
            if (!scheme.contains("AddressBase")) continue;
            String uprn = csvRecord.get(3);
            String code = csvRecord.get(5);
            hashtable.put(uprn,code);

            if (count % 10000 == 0) {
                System.out.print(".");
            }
            count++;
        }

        filename = mysqluploaddir+"1-ID32_Class_Records.csv.txt";
        FileWriter tabWriter = new FileWriter(filename);

        names = hashtable.keys();
        count = 1;

        System.out.println();
        System.out.println("Importing ID32_Class_Records.csv");

        while(names.hasMoreElements()) {

            String uprn = (String) names.nextElement();
            String code =  hashtable.get(uprn);

            String tabbed = count+d+uprn+d+code;
            tabWriter.append(tabbed);
            tabWriter.append("\n");

            if (count % 10000 == 0) {
                tabWriter.flush();
                tabWriter.close();

                System.out.print(".");

                String q = "load data infile '"+mysqldir+"1-ID32_Class_Records.csv.txt' into table uprn_v2.`uprn_class` FIELDS TERMINATED BY '\\t';";
                PreparedStatement preparedStatement = connection.prepareStatement(q);
                ResultSet rs = preparedStatement.executeQuery();
                preparedStatement.close();

                System.out.print("x");

                tabWriter = new FileWriter(filename);
            }

            count++;
        }

        tabWriter.flush();
        tabWriter.close();

        // does the file contain > 0 bytes?
        String q = "load data infile '"+mysqldir+"1-ID32_Class_Records.csv.txt' into table uprn_v2.`uprn_class` FIELDS TERMINATED BY '\\t';";
        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        preparedStatement.close();
    }

    public void IMPCLASS() throws  SQLException, IOException
    {
        String filename = pathToCsv + "ID32_Class_Records.csv";
        BufferedReader reader = new BufferedReader(
                new InputStreamReader(new FileInputStream(filename), "UTF-8"));
        CSVParser csvParser = new CSVParser(reader, CSVFormat.DEFAULT);
        Integer ft = 1;

        String q = "INSERT INTO uprn.`uprn-class` (uprn, code) values (?, ?)";
        PreparedStatement preparedStmt = connection.prepareStatement(q);

        Integer count = 1;
        for (CSVRecord csvRecord : csvParser) {
            if (ft.equals(1)) {ft=0; continue;}
            String scheme = csvRecord.get(6);
            if (!scheme.contains("AddressBase")) continue;
            String uprn = csvRecord.get(3);
            String code = csvRecord.get(5);
            System.out.println(uprn + " " + code);

            preparedStmt.setString(1, uprn);
            preparedStmt.setString(2, code);

            preparedStmt.addBatch();

            if (count % 5000 == 0) {
                preparedStmt.executeLargeBatch();
            }
            count = count + 1;
        }
    }

    public void InsertClassifications() throws SQLException, IOException
    {
        System.out.println("Importing Residential_codes.txt");
        String file = pathToCsv + "Residential_codes.txt";
        BufferedReader csvReader = new BufferedReader(new FileReader(file));
        String row = "";
        Integer ft =1;

        String q = "INSERT INTO uprn_v2.`uprn_classification` (code, term, residential) values (?, ?, ?)";
        PreparedStatement preparedStmt = connection.prepareStatement(q);

        while ((row = csvReader.readLine()) != null) {
            if (ft.equals(1)) {ft=0; continue;}
            String[] ss = row.split("\t", -1);
            String include = ss[0];
            String code = ss[1];
            String term = ss[2];

            preparedStmt.setString(1, code);
            preparedStmt.setString(2, term);
            preparedStmt.setString(3, include);

            preparedStmt.addBatch();
        }

        preparedStmt.executeLargeBatch();

        csvReader.close();
    }

    public List<List<String>> TestMySQL() throws SQLException
    {
        List<List<String>> result = new ArrayList<>();

        String preparedSql = "SELECT * FROM uprn.`uprn-class`";
        PreparedStatement preparedStatement = connection.prepareStatement( preparedSql );

        ResultSet rs = preparedStatement.executeQuery();

        while (rs.next()) {
            String uprn = rs.getString("uprn");
            String code = rs.getString("code");
            List<String> row = new ArrayList<>();
            row.add(uprn);
            row.add(code);
            result.add(row);
        }

        preparedStatement.close();

        return result;
    }

    public void close() throws SQLException {
        connection.close();
    }
}