package org.endeavourhealth.RALF;

import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;
import java.util.Properties;

public class RalfRunner {

    public static void main(String... args) throws IOException, SQLException {

        Properties properties = loadProperties( args );

        try (  generate RalfExporter = new generate( properties  ) ) {
            // C:\\Users\\PaulSimon\\Downloads\\qpost-test.txt-output.csv
            String pathToCsv = args[0];
            // C:\\Users\\PaulSimon\\Downloads\\uprn-match.EncryptedSalt
            String pathToSalt = args[1];
            // d:\\temp\\ralf_$j.txt
            String outFile = args[2];

            RalfExporter.GetRalfs(pathToCsv, pathToSalt, outFile);

        } catch (Exception e) {
            System.out.println(e);
        }
    }

    private static Properties loadProperties(String[] args) throws IOException {

        Properties properties = new Properties();

        InputStream inputStream = RalfRunner.class.getClassLoader().getResourceAsStream("ralf.exporter.properties");

        properties.load( inputStream );

        return properties;
    }

}

