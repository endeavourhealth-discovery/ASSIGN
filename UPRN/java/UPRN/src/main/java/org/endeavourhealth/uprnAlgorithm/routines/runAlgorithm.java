package org.endeavourhealth.uprnAlgorithm.routines;

import org.endeavourhealth.uprnAlgorithm.repository.Repository;

import java.sql.SQLException;
import java.util.Properties;
import java.util.Scanner;

import java.io.*;
import java.util.*;

import org.endeavourhealth.uprnAlgorithm.common.*;

public class runAlgorithm implements AutoCloseable {
	private final Repository repository;

	public runAlgorithm(final Properties properties) throws Exception {
        	this(properties, new Repository(properties));
    	}

    	public runAlgorithm(final Properties properties, final Repository repository) {
        	this.repository = repository;
    	}

	public String GetUPRN(String adrec, String qpost, String country, String summary, String orgpost) throws SQLException, IOException {

		String oadrec = adrec;

	    adrec = adrec.replaceAll(",","~");
	    adrec = adrec.toLowerCase();

	    //System.out.println(adrec);

        Hashtable<String, String> TUPRN = uprnCommon.ADRQUAL(adrec, country);
        if (TUPRN.get("INVALID") != null) {
            System.out.println(TUPRN.get("INVALID"));
            return "INVALID";
        }

		Integer length = adrec.split("~",-1).length;
		String data[] = adrec.split("~",-1);
		String post =  data[length-1];
		post = post.replaceAll("\\s","");

		// ** TO DO return hash instead
		TUPRN = MATCHONE(adrec, post, qpost, orgpost);
		if (TUPRN.get("OUTOFAREA") != null)
		{
			return "OUTOFAREA";
		}

		// format^UPRNA
		uprnCommon.format(repository, adrec, oadrec);

		return "{}"; // json
	}

	public void GetAdrFromFileAndProcess() throws IOException, SQLException
	{
		String filename = "d:\\temp\\address.txt";
		BufferedReader csvReader = new BufferedReader(new FileReader(filename));

		File f = new File("d:\\temp\\java_address.txt");
		if(f.exists() && !f.isDirectory()) {
			f.delete();
		}

		String F2 = "d:\\temp\\java_address.txt";
		FileWriter fw = new FileWriter(F2,true); //the true will append the new data
		fw.write("candidate" +"\t"+ "building" +"\t"+ "deploc" +"\t"+ "depth" + "\t"+ "flat" + "\t"+ "locality" + "\t"+ "number" +"\t"+ "postcode" +"\t"+ "street" + "\t"+ "town" +"\n");
		fw.close();

		String row = "";
		Integer count = 1; Integer ft =1 ;
		while ((row = csvReader.readLine()) != null) {
			if (ft.equals(1)) {ft=0; continue;}
			String[] data = row.split("\t",-1);
			String adrec = data[0];
			System.out.println(adrec);

			String json = GetUPRN(adrec, "","","","");

			if (count % 10000 == 0) {
				System.out.print(".");
			}
			count++;
		}
		csvReader.close();
	}

	public Hashtable<String, String> MATCHONE(String adrec, String post, String qpost, String orgpost) throws SQLException
	{
		Hashtable<String, String> hashTable = new Hashtable<String, String>();

		adrec = adrec.toLowerCase();

		if (!post.isEmpty()) {
			if (uprnCommon.validp(post).equals(1)) {
				String area = uprnCommon.area(post);
				Integer in = uprnCommon.inpost(repository, area, qpost);
				if (in.equals(0)) {
					hashTable.put("OUTOFAREA","Null address lines");
					return hashTable;
				}
			}
		}

		return hashTable;
	}

	@Override
	public void close() throws Exception {
		repository.close();
	}

}