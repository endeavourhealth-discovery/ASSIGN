package org.endeavourhealth.uprnAlgorithm;

import java.util.Properties;
import java.io.IOException;
import java.sql.SQLException;
import java.io.InputStream;
import java.util.Scanner;

import org.endeavourhealth.uprnAlgorithm.routines.*;

public class uprnAlgorithm {
	public static void main(String... args) throws IOException, SQLException {
	
		Properties properties = loadProperties( args );

        if (args.length>=1 && args[0].equalsIgnoreCase("CONSOLE")) {
            try ( runAlgorithm z = new runAlgorithm(properties) ) {

                Scanner scanner = new Scanner(System.in);
                System.out.print("Enter an address: ");
                String adrec = scanner.nextLine();

                z.GetUPRN(adrec, "","","");
            }
            catch (Exception e) {
                System.out.println(e);
                e.printStackTrace();
            }
            System.exit(0);
        }

        if (args.length>=1 && args[0].equalsIgnoreCase("RUN")) {
            try ( runAlgorithm z = new runAlgorithm(properties) ) {
                //z.GetUPRN();
            }
            catch (Exception e) {
                System.out.println(e);
                e.printStackTrace();
            }
            System.exit(0);
        }
	}
	
    private static Properties loadProperties(String[] args) throws IOException {

        Properties properties = new Properties();

        InputStream inputStream = uprnAlgorithm.class.getClassLoader().getResourceAsStream("uprn.algorithm.properties");

        properties.load( inputStream );

        return properties;
    }	
}	