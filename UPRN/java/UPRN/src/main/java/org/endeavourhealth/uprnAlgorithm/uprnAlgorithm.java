package org.endeavourhealth.uprnAlgorithm;

import java.util.Properties;
import java.io.IOException;
import java.sql.SQLException;
import java.io.InputStream;
import java.util.Scanner;

import org.endeavourhealth.uprnAlgorithm.routines.*;

import static org.endeavourhealth.uprnAlgorithm.common.uprnCommon.Piece;

public class uprnAlgorithm {
	public static void main(String... args) throws IOException, SQLException {
	
		Properties properties = loadProperties( args );

        for (String s: args) {
            String ss = Piece(s,":",1,1);
            if (ss.equals("commercials")) {
                properties.setProperty("commercials", Piece(ss,":",2,2));
            }
        }

		if (args.length>=1 && args[0].equalsIgnoreCase("TESTUPRNA")) {
            try ( runAlgorithm z = new runAlgorithm(properties) ) {
                z.GetAdrFromFileAndProcess();
            }
            catch (Exception e) {
                System.out.println(e);
                e.printStackTrace();
            }
            System.exit(0);
        }

        if (args.length>=1 && args[0].equalsIgnoreCase("CONSOLE")) {
            try ( runAlgorithm z = new runAlgorithm(properties) ) {

                // 10 Downing St,Westminster,London,SW1A2AA
                // flat 1 anglian house,,,,106 renwick road,ig110rf
                // 1 st. helens road,,,,ilford,ig13qj
                // 0.1 the askew building,50 bartholomew close,,,london,ec1a7bd
                // 0.1 the askew building,50 bartholomew close,,, london, ec1a7bd
                // flat 1 to - 2 anglian house,,,,106 renwick road,ig110rf

                // 02 Belgrave Road,,,,London,E178QG <= addlines should be 1
                // 1 Attlee Terrace Prospect Hill,Walthamstow, London,,,London,E173EG <= addlines should be 2
                // 02 Saddleworth Square,Harold Hill,,,Romford,RM38YX <= addlines should be 3
                // 92~summit estate~portland avenue~stamford hill~n166ea <= f4
                // room 6 house~27~p o box 1558~n165jj <= f5
                // pentland house~30 stamford hill~stamford hill~n166xz <= f6
                // 11a northfield road~n165rl <= f8
                // flat 1 157 chruch walk~n168qa <= f9

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