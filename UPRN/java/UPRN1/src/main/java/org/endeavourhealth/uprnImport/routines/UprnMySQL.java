package org.endeavourhealth.uprnImport.routines;

import com.mysql.cj.x.protobuf.MysqlxPrepare;
import com.sun.media.jfxmediaimpl.platform.gstreamer.GSTPlatform;
import com.sun.xml.internal.ws.policy.privateutil.PolicyUtils;
import org.endeavourhealth.uprnImport.repository.Repository;
import org.endeavourhealth.uprnImport.routines.export;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Hashtable;
import java.util.List;
import java.util.Properties;

public class UprnMySQL implements AutoCloseable {

    private final Repository repository;

    public UprnMySQL(final Properties properties) throws Exception {
        this(properties, new Repository(properties));
    }

    public UprnMySQL(final Properties properties, final Repository repository) {
        this.repository = repository;
    }

   public void Test() throws SQLException {
        RunMySQL test = new RunMySQL();
        test.Run(repository);
   }

   public void LoadClassification() throws SQLException, IOException {
       repository.InsertClassifications();
   }

   public void IMPCLASS() throws SQLException, IOException {
       repository.IMPCLASS2();
   }

   public void IMPSTR() throws SQLException, IOException {
       repository.IMPSTR2();
   }

    public void IMPUPC() throws SQLException, IOException {
        RunMySQL stub = new RunMySQL();
        stub.IMPUPC(repository);
    }

   public void IMPBLP2() throws SQLException, IOException {
       repository.IMPBPL2();
   }

   public void IMPDPA() throws SQLException, IOException {
       repository.IMPDPA2();
   }

   public void IMPLPI() throws SQLException, IOException, InterruptedException {

       // split the file up into 1 million records
       // cannot do this - since we want to make records unique using uprn & key

       //String filename = repository.pathToCsv + "ID24_LPI_Records.csv";
       //repository.IMPLPI2(filename);

       Integer ft = 1; String row = "";

       String filename = repository.pathToCsv + "ID24_LPI_Records.csv";
       BufferedReader csvReader = new BufferedReader(new FileReader(filename));

       Hashtable<String, String> hashtable =
               new Hashtable<String, String>();

       String newfile = repository.pathToCsv + "LPI_new.csv";
       FileWriter newWriter = new FileWriter(newfile);

       System.out.println("Identifying LPI records");

       Integer count = 1;
       while ((row = csvReader.readLine()) != null) {
           if (ft.equals(1)) {
               ft = 0;
               continue;
           }

           row = row.replace("\"","");

           String[] data = row.split(",",-1);
           String uprn = data[3];
           String key = data[4];

           if (count % 10000 == 0) {
               System.out.print(".");
           }

           hashtable.put(uprn+"~"+key, count.toString());
           count++;
       }

       csvReader.close();

       csvReader = new BufferedReader(new FileReader(filename));

       newWriter.append("HEADER");
       newWriter.append("\n");

       System.out.println("\nWriting new LPI file to disk");
       // loop down the LPI file (again) and write out the latest records
       count = 1; ft = 1;
       while ((row = csvReader.readLine()) != null) {
           if (ft.equals(1)) {
               ft = 0;
               continue;
           }

           String zrow = row.replace("\"","");
           zrow = zrow.replace("\"","");

           String[] data = zrow.split(",",-1);
           String uprn = data[3];
           String key = data[4];

           String zcount = hashtable.get(uprn+"~"+key);

           if (Integer.parseInt(zcount) == count) {
               newWriter.append(row);
               newWriter.append("\n");
           }

           if (count % 10000 == 0) {
               System.out.print(".");
           }

           count ++;
       }

       csvReader.close();
       newWriter.close();

       System.out.println("\nFinished!");

       hashtable.clear();

       repository.IMPLPI2(newfile);
   }

   public void UPRNS() throws SQLException, IOException {
       repository.UPRNS();
   }

   public void IMPABP() throws SQLException, IOException {
        repository.IMPABP();
   }

   public void TurnIntoTab() throws IOException, SQLException {
        //repository.TurnFileIntoTabDelimeted("D:\\TEMP\\epochs\\BASE\\ID15_StreetDesc_Records.csv","1-street-desc.txt","75");
       // repository.TurnFileIntoTabDelimeted("D:\\TEMP\\epochs\\BASE\\ID21_BLPU_Records.csv","1-blpu-records.txt","75","abp.`blpu_records`");
       //repository.TurnFileIntoTabDelimeted("D:\\TEMP\\epochs\\BASE\\ID24_LPI_Records.csv","1-lpi-records.txt","75","abp.`lpi_records`");
       //repository.TurnFileIntoTabDelimeted("D:\\TEMP\\epochs\\BASE\\ID28_DPA_Records.csv","1-dpa-records.txt","75","abp.`dpa_records`");
       repository.TurnFileIntoTabDelimeted("D:\\TEMP\\epochs\\BASE\\ID32_Class_Records.csv","1-class-records.txt","75","abp.`class_records`");
   }

   public void UPRNIND() throws SQLException, IOException {
       repository.UPRNINDMAIN();
   }

    @Override
    public void close() throws Exception {
        repository.close();
    }
}