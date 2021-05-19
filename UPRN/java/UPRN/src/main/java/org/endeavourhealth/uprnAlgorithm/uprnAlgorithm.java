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

                // 10 Downing St,Westminster,London,SW1A2AA
                // flat 1 anglian house,,,,106 renwick road,ig110rf
                // 1 st. helens road,,,,ilford,ig13qj
                // 0.1 the askew building,50 bartholomew close,,,london,ec1a7bd
                // 0.1 the askew building,50 bartholomew close,,, london, ec1a7bd
                // flat 1 to - 2 anglian house,,,,106 renwick road,ig110rf

                Scanner scanner = new Scanner(System.in);
                System.out.print("Enter an address: ");
                String adrec = scanner.nextLine();

                String json = z.GetUPRN(adrec, "","","","");
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