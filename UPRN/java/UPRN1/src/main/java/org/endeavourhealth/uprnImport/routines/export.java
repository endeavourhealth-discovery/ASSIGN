package org.endeavourhealth.uprnImport.routines;

import java.io.*;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.endeavourhealth.uprnImport.repository.Repository;

public class export  {
    public static void Classiication(String pathToCsv) throws IOException {
        BufferedReader csvReader = new BufferedReader(new FileReader(pathToCsv));
        String row = ""; String resource_guid = ""; String json = "";
        Integer ft =1;
        while ((row = csvReader.readLine()) != null) {
            if (ft.equals(1)) {ft=0; continue;}
            String[] ss = row.split("\t", -1);
            String include = ss[0];
            String code = ss[1];
            String term = ss[2];
            System.out.println(include);
            System.out.println(code);
            System.out.println(term);
        }
        csvReader.close();
    }

    public static void IMPBLP(String pathToCsv) throws IOException {
        String filename = pathToCsv + "ID21_BLPU_Records.csv";
        BufferedReader reader = new BufferedReader(
                new InputStreamReader(new FileInputStream(filename), "UTF-8"));
        CSVParser csvParser = new CSVParser(reader, CSVFormat.DEFAULT);

        FileWriter tabWriter = new FileWriter(pathToCsv+"ID21_BLPU_Records.txt");

        Integer ft = 1; Integer count = 1;
        String d = "\t";
        for (CSVRecord csvRecord : csvParser) {
            if (ft.equals(1)) {ft=0; continue;}
        }

        tabWriter.flush();
        tabWriter.close();
    }

    public static void IMPCLASS(String pathToCsv) throws IOException {
        String filename = pathToCsv + "ID32_Class_Records.csv";
        BufferedReader reader = new BufferedReader(
                new InputStreamReader(new FileInputStream(filename), "UTF-8"));
        CSVParser csvParser = new CSVParser(reader, CSVFormat.DEFAULT);

        filename = pathToCsv + "1-ID32_Class_Records.csv.txt";
        FileWriter tabWriter = new FileWriter(filename);

        Integer ft = 1; Integer count = 1; Integer fileCount=2;
        String d = "\t";

        System.out.println(filename);

        for (CSVRecord csvRecord : csvParser) {
            if (ft.equals(1)) {ft=0; continue;}
            String scheme = csvRecord.get(6);
            if (!scheme.contains("AddressBase")) continue;
            String uprn = csvRecord.get(3);
            String code = csvRecord.get(5);
            // write to disk
            String tabbed = count+d+uprn+d+code;
            tabWriter.append(tabbed);
            tabWriter.append("\n");

            if (count % 200000 == 0) {
                tabWriter.flush();
                tabWriter.close();
                filename=fileCount+"-ID32_Class_Records.csv.txt";
                fileCount++;
                tabWriter = new FileWriter(pathToCsv+filename);
                System.out.println(filename);
            }
            count = count +1;
        }
        tabWriter.flush();
        tabWriter.close();
    }
}