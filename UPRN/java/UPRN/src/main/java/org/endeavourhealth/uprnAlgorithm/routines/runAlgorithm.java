package org.endeavourhealth.uprnAlgorithm.routines;

import com.sun.deploy.security.SelectableSecurityManager;
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

	public List<List<String>> TUPRN;
	public Hashtable<String, String> TUPRNV;

	public runAlgorithm(final Properties properties) throws Exception {
		this(properties, new Repository(properties));
	}

	public runAlgorithm(final Properties properties, final Repository repository) {
		this.repository = repository;
	}

	public String GetUPRN(String adrec, String qpost, String country, String summary, String orgpost) throws SQLException, IOException {

		String oadrec = adrec;

		adrec = adrec.replaceAll(",", "~");
		adrec = adrec.toLowerCase();

		//System.out.println(adrec);

		TUPRNV = uprnCommon.ADRQUAL(adrec, country);
		if (TUPRNV.get("INVALID") != null) {
			System.out.println(TUPRNV.get("INVALID"));
			//return "INVALID";
		}

		Integer length = adrec.split("~", -1).length;
		String data[] = adrec.split("~", -1);
		String post = data[length - 1];
		post = post.replaceAll("\\s", "");

		// ** TO DO return hash instead
		MATCHONE(adrec, post, qpost, orgpost, oadrec);
		if (TUPRNV.get("OUTOFAREA") != null) {
			//return "OUTOFAREA";
		}

		// populate the json with the address base premium data
		// or, do we populate the json with the original table data?


		/*
        for(List<String> rec : TUPRN)
        {
            String uprn = rec.get(0);
            String table = rec.get(1);
            String key = rec.get(2);
            String ALG = rec.get(3);
            String matchrec = rec.get(4);
        }
		*/

		String json = "{";
		json = QUALCHK(json);
		json = MATCHK(json);

		json = json + "}";
		return json;
	}

	public String MATCHK(String json) throws SQLException {
		// MATCHK^UPRNMGR
		json = json + "\"Matched\":";

		if (TUPRNV.get("NOMATCH") != null || TUPRNV.get("OUTOFAREA") != null) {
			json = json + "false";
		} else {
			json = json + "true,";
		}

		if (TUPRNV.get("MATCHED") != null) {
			if (!TUPRN.get(0).isEmpty()) {
				List<String> rec = TUPRN.get(0);
				String uprn = rec.get(0);
				String table = rec.get(1);
				String key = rec.get(2);
				String alg = rec.get(3);
				String matchrec = rec.get(4);
				json = json + "\"UPRN\":\"" + uprn + "\",";
				json = json + "\"Qualifier\":\""+qual(matchrec)+"\"";

				String classcode = repository.ClassCode(uprn);
				String classterm = "";
				if (!classcode.isEmpty()) {
					classterm = repository.ClassTerm(classcode);
				}

				json = json + ",\"Classification\":\""+ classcode + "\",";
				json = json + "\"ClassTerm\":\""+classterm + "\"";

				json = json+",";

				String abp = repository.GETADRABP(uprn, table, key);

				String post = Piece(abp,"~",1,1); String org = Piece(abp,"~",2,2);
				String dep = Piece(abp,"~",3,3); String flat = Piece(abp,"~",4,4);
				String build = Piece(abp,"~",5,5); String bno=Piece(abp,"~",6,6);
				String depth = Piece(abp,"~",7,7); String street = Piece(abp,"~",8,8);
				String deploc = Piece(abp,"~",9,9); String loc = Piece(abp,"~",10,10);
				String town = Piece(abp,"~",11,11); String ptype = Piece(abp,"~",12,12);
				String suff = Piece(abp,"~",13,13);

				// $$repost^UPRN2(post)
				// will need to reform the post code - if the postcode comes form the uprn_original

				json = json + "\"Algorithm\":\""+alg+"\",";
				json =json+"\"ABPAddress\":{";

				if (!flat.isEmpty()) {

				}

				if (!build.isEmpty()) {

				}

				if (!bno.isEmpty()) {

				}

				json = pattern(matchrec, json);
				System.out.println(matchrec);
			}
		}

		System.out.println(json);

		return json;
	}

	public String qual(String matchrec)
	{
		if (matchrec.isEmpty()) return "";
		if (matchrec.contains("c")) return "Child";
		if (matchrec.contains("a")) return "Parent";
		if (matchrec.contains("s")) return "Sibling";

		String qual = "Best ";
		if (repository.commercials.equals("0")) {
			qual = qual+"(residential)";}
		else { qual = qual+"(commercial)";}

		qual = qual+" match";
		return qual;
	}

	public String QUALCHK(String json) {
		json = json+"\"Address_format\":";
		if (TUPRNV.get("INVALID") != null) {
			json = json +"\""+TUPRNV.get("INVALID")+"\",";}
		else
		{
			json = json + "\"good\"";
		}

		json = json +"\"Postcode quality\":";
		if (TUPRNV.get("POSTCODE")!=null) {
			json = json + "\"" + TUPRNV.get("POSTCODE") + "\",";}
		else
		{
			json = json+"\"good\",";
		}

		return json;
	}

	public String pattern(String matchrec, String json) {

	    json = json +"\"Match_pattern:\":\"";
	    Integer i;
	    for (i=1; i<=CountPieces(matchrec,","); i++) {
            String part = Piece(matchrec,",",i,i);
            if (part.length()<2) continue;
            String degree = part.substring(1,2);
            json = json+"\""+part(part.substring(0,1)) + "\":";
            json = json+"\""+degree(degree)+"\",";
        }

	    if (json.substring(json.length()-1,json.length()).equals(",")) {
	    	json = json.substring(0, json.length()-1);
		}

	    json = json+"}";

		return json;
    }

	public String part(String part) {
	    String ret = "";
	    part = part.toLowerCase();
	    if (part.equals("p")) return "Postcode";
	    if (part.equals("s")) return "Street";
	    if (part.equals("n")) return "Number";
	    if (part.equals("b")) return "Building";
	    if (part.equals("f")) return "Flat";
	    return "";
    }

    public String degree(String degree) {
	    String result = "";

	    if (degree.contains("&")) {
	        result = "mapped also to "+part(Piece(degree,"&",2,2)) + " ";
        }

	    if (degree.contains(">")) {
	        result = "moved to "+part(Piece(degree,">",2,2))+" ";
        }

        if (degree.contains("<")) {
            result = "moved to "+part(Piece(degree,"<",2,2))+" ";
        }

        if (degree.contains("f")) {
            if (result.isEmpty()) result = "field merged";
            else {
                result = result + " field merged";
            }
        }

        if (degree.contains("i")) {
            result = "ABP field ignored";
        }

        for (;;) {
            if (degree.contains("d")) {
                if (degree.contains("xd")) {
                    result = Space(result)+"candidate prefix dropped to match";
                    break;
                }
                result = "candidate field dropped";
            }
            break;
        }

        if (degree.contains("e")) {result = "equivalent";}
        if (degree.contains("l")) {result = result + "possible spelling error";}

        if (degree.contains("a")) {result= Space(result) + "matched as parent";}
        if (degree.contains("c")) {result= Space(result) + "matched as child";}
        if (degree.contains("s")) {result= Space(result) + "matched as sibling";}
        if (degree.contains("p")) {result= Space(result) + "partial match";}
        if (degree.contains("v")) {result= Space(result) + "level based match";}
        if (degree.contains("xd")) {result= Space(result) + "level based match";}

	    return result;
    }

    public String Space(String result) {
        if (!result.isEmpty()) result = result+" ";
	    return result;
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

	public void MATCHONE(String adrec, String post, String qpost, String orgpost, String oadrec) throws IOException, SQLException
	{
		Hashtable<String, String> hashTable = new Hashtable<String, String>();

		adrec = adrec.toLowerCase();

		if (!post.isEmpty()) {
			if (uprnCommon.validp(post).equals(1)) {
				String area = uprnCommon.area(post);
				Integer in = uprnCommon.inpost(repository, area, qpost);
				if (in.equals(0)) {
					hashTable.put("OUTOFAREA","Null address lines");
					return;
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
		String original = Piece(ret,"~",9,9);

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
		Integer matched = match(adflat, adbuild, adbno, adepth, adstreet, adeploc, adloc, adpost, adf2, adb2, indrec, indprec, original, adplural);
		if (matched.equals(0)) {
			TUPRNV.put("NOMATCH","1");
		}
		else {
			TUPRNV.put("MATCHED","1");
		}
	}

	public Integer match(String adflat, String adbuild, String adbno, String adepth, String adstreet, String adeploc, String adloc, String adpost, String adf2, String adb2, String indrec, String indprec, String orginal, Integer adplural) throws SQLException
	{
		// ;Match algorithms

		// ;Reject crap codes
		if (adflat.isEmpty() && adbuild.isEmpty() && adbno.isEmpty() && adstreet.isEmpty() && adeploc.isEmpty()) return 0;

		// ;Full match on post,street, building and flat
		// ;Try concatenated fields

		// 1
		Integer matched = matchall(indrec, adplural, indprec);

		return matched;
	}

	public Integer matchall(String indrec, Integer adplural, String indprec) throws SQLException
	{
		String matchrec = "Pe,Ne,Be,Fe";
		String ALG = "1-match";

		System.out.println(indrec);

		Integer matched = 0;
		String q = "";

		if (repository.X(indrec).equals(1)) {
			ALG = "1-match";
			q = "select * from uprn_v2.uprn_main where indrec ='"+indrec+"' and node='X';";
            matched  = setuprns("X",indrec,"","","","",q,ALG,matchrec);
            System.out.println("evaluate TUPRN");
            return matched;
		}

		if (adplural.equals(1)) {
            if (repository.X(indprec).equals(1)) {
                ALG = "2-match";
                matched  = setuprns("X",indprec,"","","","",q,ALG,matchrec);
            }
        }

		return matched;
	}

	public Integer setuprns(String index, String n1, String n2, String n3, String n4, String n5, String q, String ALG, String matchrec) throws SQLException
	{
	    TUPRN = repository.RunUprnMainQuery(q, ALG, matchrec);
		return 1;
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