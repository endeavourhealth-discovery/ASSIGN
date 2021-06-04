package org.endeavourhealth.uprnAlgorithm.routines;

import org.endeavourhealth.uprnAlgorithm.repository.Repository;

import java.sql.SQLException;
import java.util.Properties;
import java.util.Scanner;

import java.io.*;
import java.util.*;

import org.endeavourhealth.uprnAlgorithm.common.*;

import static org.endeavourhealth.uprnAlgorithm.common.uprnCommon.*;

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
		TUPRN = MATCHONE(adrec, post, qpost, orgpost, oadrec);
		if (TUPRN.get("OUTOFAREA") != null)
		{
			return "OUTOFAREA";
		}

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

	public Hashtable<String, String> MATCHONE(String adrec, String post, String qpost, String orgpost, String oadrec) throws IOException, SQLException
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

		// format^UPRNA
		String ret = uprnCommon.format(repository, adrec, oadrec);

		String adflat = Piece(ret,"~",1,1);
		String adbuild = Piece(ret,"~",2,2);
		String adbno = Piece(ret,"~",3,3);
		String adstreet = Piece(ret,"~",4,4);
		String adloc = Piece(ret,"~",5,5);
		String adpost = Piece(ret,"~",6,6);
		String adepth = Piece(ret,"~",7,7);
		String adeploc = Piece(ret,"~",8,8);

		String adpstreet = plural(adstreet);
		String adpbuild = plural(adbuild);
		String adflatbl = flat(adbuild+" ", repository);

		Integer adplural = 0;
		if (!adpstreet.equals(adstreet)) adplural=1;
		if (!adpbuild.equals(adbuild)) adplural=1;

		String adb2="";
		String adf2 = "";

		// adflat?1n.n1" "1l.l <= test this in mumps
		if (!adbuild.isEmpty() && RegEx(adflat, "^(\\d+( )[a-z]+)$").equals(1)) {
			adb2 = Piece(adflat, " ", 2, 10)+" "+adbuild;
			adf2 = Piece(adflat, " ", 1, 1);
		}

		String indrec = adpost +" "+ adflat +" "+ adbuild +" "+ adbno +" "+ adepth +" "+ adstreet +" "+ adeploc +" "+ adloc;

		for (;;) {
			indrec = indrec.replace("  ", " ");
			if (!indrec.contains("  ")) break;
		}

		indrec = indrec.trim();

		String indprec = "";
		if (adplural.equals(1)) {
			indprec = adpost +" "+ adflat +" "+ adpbuild +" "+ adbno +" "+ adepth +" "+ adpstreet +" "+ adeploc +" "+ adloc;
			indprec = indprec.replace("  ", " ").trim();
		}

		// ;Exact match all fields directly i.e. 1 candidate
		ret = match(adflat, adbuild, adbno, adepth, adstreet, adeploc, adloc, adpost, adf2, adb2, indrec, indprec);

		return hashTable;
	}

	public String match(String adflat, String adbuild, String adbno, String adepth, String adstreet, String adeploc, String adloc, String adpost, String adf2, String adb2, String indrec, String indprec) throws SQLException
	{
		// ;Match algorithms

		// ;Reject crap codes
		if (adflat.isEmpty() && adbuild.isEmpty() && adbno.isEmpty() && adstreet.isEmpty() && adeploc.isEmpty()) return "";

		// ;Full match on post,street, building and flat
		// ;Try concatenated fields

		// 1
		String ret = matchall(indrec);

		return "";
	}

	public String matchall(String indrec) throws SQLException
	{
		String matchrec = "Pe,Ne,Be,Fe";
		String ALG = "";

		System.out.println(indrec);

		if (repository.X(indrec).equals(1)) {
			ALG = "1-match";

		}
		return "";
	}

	public String setuprns(String index, String n1, String n2, String n3, String n4, String n5)
	{
		return "";
	}

	public String set(String uprn, String table, String key)
	{
		return "";
	}

	@Override
	public void close() throws Exception {
		repository.close();
	}

}