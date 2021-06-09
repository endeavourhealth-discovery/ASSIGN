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

		System.out.println(json);

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

				String post = Piece(abp,"~",1,1); String org = Ini(Piece(abp,"~",2,2));
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
					json = json+"\"Flat\":\""+flat+"\",";
				}

				if (!build.isEmpty()) {
					json = json+"\"Building\":\""+build+"\",";
				}

				if (!bno.isEmpty()) {
					json = json+"\"Number\":\""+bno+"\",";
				}

				if (!depth.isEmpty()) {
					json = json+"\"Dependent_thoroughfare\":\""+depth+"\",";
				}

				if (!street.isEmpty()) {
					json = json+"\"Street\":\""+Ini(street)+"\",";
				}

				if (!deploc.isEmpty()) {
					json = json +"\"Dependent_locality\":\""+deploc+"\",";
				}

				if (!loc.isEmpty()) {
					json = json +"\"Locality\":\""+loc+"\",";
				}

				if (!town.isEmpty()) {
					json = json+"\"Town\":\""+town+"\",";
				}

				if (!post.isEmpty()) {
					json = json+"\"Postcode\":\""+post+"\",";
				}

				if (!org.isEmpty()) {
					json = json+"\"Organisation\":\""+org+"\",";
				}

				if (json.substring(json.length()-1,json.length()).equals(",")) {
					json = json.substring(0, json.length()-1);
				}

				json = json+"},";

				json = pattern(matchrec, json);
			}
		}
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
			json = json + "\"good\",";
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

	    json = json +"\"Match_pattern:\":{";
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

		/*
		System.out.println(extract("abc",2,3));
		System.out.println(Ini("aaaa bbbb"));

		Integer t = min(10,2,5);

		Integer levensh = levensh("treehavencourt","takeleycourt",10,0);
		 */


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
		Integer matched = match(adflat, adbuild, adbno, adepth, adstreet, adeploc, adloc, adpost, adf2, adb2, indrec, indprec, original, adplural, adpstreet, adpbuild);
		if (matched.equals(0)) {
			TUPRNV.put("NOMATCH","1");
		}
		else {
			TUPRNV.put("MATCHED","1");
		}
	}

	public Integer match(String adflat, String adbuild, String adbno, String adepth, String adstreet, String adeploc, String adloc, String adpost, String adf2, String adb2, String indrec, String indprec, String orginal, Integer adplural, String adpstreet, String adpbuild) throws SQLException
	{
		// ;Match algorithms

		// ;Reject crap codes
		if (adflat.isEmpty() && adbuild.isEmpty() && adbno.isEmpty() && adstreet.isEmpty() && adeploc.isEmpty()) return 0;

		// ;Full match on post,street, building and flat
		// ;Try concatenated fields

		// 1
		Integer matches = matchall(indrec, adplural, indprec);
		if (matches.equals(1)) return 1;

		// ** TO DO
		// s matches=$$matchall($g(address("original")))

		// Exact field match single and plural and correction
		// 10
		String ALG="10-";
		String matchrec="Pe,Se";
		matches = match1(adpost, adstreet, adbno, adbuild, adflat, matchrec, ALG);
		if (matches.equals(1)) return 1;

		if (adplural.equals(1)) {
			matches = match1(adpost, adpstreet, adbno, adpbuild, adflat, matchrec, ALG);
		}
		if (matches.equals(1)) return 1;

		String corstr = correct(adstreet, repository);
		if (!corstr.equals(adstreet)) {
			matches = match1(adpost, corstr, adbno, adbuild, adflat, matchrec, ALG);
		}
		if (matches.equals(1)) return 1;

		// ;Full match on dependent street
		if (!adepth.isEmpty()) {
			// 20 (20-match1 does not exist in patient_address_match)
			ALG = "20-";
			matches = match1(adpost, adepth + " " + adstreet, adbno, adbuild, adflat, matchrec, ALG);
			if (matches.equals(1)) return 1;
			if (adplural.equals(1)) {
				matches = match1(adpost, adepth + " " + adpstreet, adbno, adpbuild, adflat, matchrec, ALG);
				if (matches.equals(1)) return 1;
			}
			// flat 3, Quarles Park Road, Watermark Court, Chadwell Heath, Romford, RM64DJ
			// import needs fixing (or investigating) - "flat 3" recorded in covering indexes rather than just 3
			ALG = "30-";
			matches = match1(adpost, adepth, adbno, adbuild, adflat, matchrec, ALG);
			if (matches.equals(1)) return 1;
			if (adplural.equals(1)) {
				matches = match1(adpost, adepth, adbno, adpbuild, adflat, matchrec, ALG);
				if (matches.equals(1)) return 1;
			}
		}

		// 35 ;Flat in number
		// ?1n.n1l
		if (RegEx(adbno, "^[0-9]+[a-z]$").equals(1) && adflat.isEmpty() && adbuild.isEmpty()) {
			ALG = "35-";
			String zadbno = extractNumber(adbno);
			matches = match1(adpost, adstreet, zadbno, adbuild, Piece(adbno,zadbno,2,2), matchrec, ALG);
			if (matches.equals(1)) return 1;
		}

		// 36 Building in flat
		// ?1n.n.l1" "1l.e
		if (RegEx(adflat, "^[0-9]+|[0-9]+[a-z]( )[a-z]\\w+").equals(1)) {
			ALG = "36-";
			// 26 Nash House, Walthamstow, Prospect Hill, E17 3EW
			matches = match1(adpost, adstreet, adbno, Piece(adflat," ",2,10), Piece(adflat," ",1,1), matchrec, ALG);
			if (matches.equals(1)) return 1;
		}

		// 37 ;Flat contains number and suffix. Street and building
		// 1n.n1l
		if (RegEx(adflat, "^[0-9]+[a-z]$").equals(1)) {
			ALG="37-";
			// 23B Park Road,Leyton,,,Waltham Forest,E107DB
			String zadflat = extractNumber(adflat);
			matches = match1(adpost, adbuild, zadflat, "", Piece(adflat, zadflat,2,2), matchrec, ALG);
			if (matches.equals(1)) return 1;
		}

		// 40 ;Full match Swap building flat with number and street
		ALG = "40-";
		// 22B Sutherland Road,3 St Claude House,,,Walthamstow,E176BH
		matches = match1(adpost, adbuild, adflat, adstreet, adbno, matchrec, ALG);
		if (matches.equals(1)) return 1;
		matches = match1(adpost, adbuild, adbno, adstreet, adflat, matchrec, ALG);
		if (matches.equals(1)) return 1;
		if (adplural.equals(1)) {
			matches=match1(adpost, adpbuild, adflat, adstreet, adbno, matchrec, ALG);
			if (matches.equals(1)) return 1;
		}

		// 50
		//;Full match locality swap for street
		if (matches.equals(0) && !adloc.isEmpty()) {
			ALG="50-";
			// 1 Kebbel Terrace,Claremont Road,Forest Gate,,London,E70QP
			matchrec="Pe,Se";
			matches = match1(adpost, adloc, adbno, adpbuild, adflat, matchrec, ALG);
			if (matches.equals(1)) return 1;
			if (adplural.equals(1)) {
				matches = match1(adpost, adloc, adbno, adpbuild, adflat, matchrec, ALG);
				if (matches.equals(1)) return 1;
			}
		}

		// 60
		// 226-228,Oaks Court, Cann Hall Road,,,Leytonstone,E113NF
		if (matches.equals(0)) {
			ALG="60-";
			matches = match4(adpost, adstreet, adbno, adbuild, adflat, matchrec, ALG);
			if (matches.equals(1)) return 1;
			if (adplural.equals(1)) {
				matches = match4(adpost, adpstreet, adbno, adpbuild, adflat, matchrec, ALG);
			}
		}
		if (matches.equals(1)) return 1;

		// 65 ;Flat is number, partial building
		// Flat 6 Treehaven Court,Skeltons Lane,,,Leyton,E105BX
		if (adbno.isEmpty()) {
			ALG = "65-";
			matches = match33(adpost, adstreet, adbno, adbuild, adflat, matchrec, ALG);
		}
		if (matchrec.equals(1)) return 1;

		return matches;
	}

	public Integer match33(String tpost, String tstreet, String tbno, String tbuild, String tflat, String matchrec, String ALG) throws SQLException
	{
		Integer matches = 0;

		if (repository.X5$D1(tpost, tstreet, tflat).equals(0)) return 0;
		if (tflat.isEmpty()) return 0;

		// get all the buildings for tpost, tstreet, tflat
		// for  s build=$O(^UPRNX("X5",tpost,tstreet,tflat,build))
		// select * from uprn_v2.uprn_main where node = 'X5' and post=tpost and street=tstreet and flat=tflat

		List<List<String>> buildings = repository.match33(tpost, tstreet, tflat);

		for(List<String> rec : buildings)
		{
			System.out.println(rec.get(0)); // build
			String build = rec.get(0);
			if (equiv(tbuild,build,"","",repository).equals(0)) {
				matches = match33a(tbuild, build, tpost, tstreet, tflat);
				if (matches.equals(1)) return 1;
				continue;
			}
			if (partial(tbuild, build, repository).equals(1)) {
				matches = match33a(tbuild, build, tpost, tstreet, tflat);
				if (matches.equals(1)) return 1;
				continue;
			}
		}

		return matches;
	}

	public Integer match33a(String tbuild, String build, String tpost, String tstreet, String tflat)
	{
		Integer matched = 0;
		// select * from uprn_v2.uprn_main where node = 'X5' and and post=tpost and street=tstreet and flat=flat and bno=flat
		// 65-match33a
		// ds33a
		if (tflat.isEmpty()) {

		}

		// i '$d(^UPRNX("X5",tpost,tstreet,tflat,build,"")) q

		return matched;
	}

	//  ;Try swapping flat and building
	public Integer match4(String tpost, String tstreet, String tbno, String tbuild, String tflat, String matchrec, String ALG) throws SQLException
	{
		// only swap if flat does not exist
		Integer matches = 0;
		if (repository.X3$Data(tbuild, tflat).equals(1)) return 0;
		matches = match1(tpost, tstreet, tflat, tbuild, tbno, matchrec, ALG);
		if (matches.equals(1)) return 1;
		// ?1n.n.l1" "1l.e
		if (RegEx(tbuild, "^[0-9]+|[0-9]+[a-z]( )[a-z]\\w+").equals(1) && !tbuild.isEmpty() && !tflat.isEmpty()) {
			matches = match1(tpost, tstreet, tbno, Piece(tbuild," ",2,10), Piece(tbuild," ",1,1)+" "+tflat,matchrec,ALG);
			if (matches.equals(1)) return 1;
		}
		matches = match1(tpost, tstreet, tflat, tbuild, tbno, matchrec, ALG);
		return matches;
	}

	// ;Match algorithms on a post code and street
	public Integer match1(String tpost, String tstreet, String tbno, String tbuild, String tflat, String matchrec, String ALG) throws SQLException
	{
		Integer matches = 0;
		// ;Full 5 field match
		if (repository.X5(tpost, tstreet, tbno, tbuild, tflat).equals(1)) {
			matchrec = Piece(matchrec,",",1,2)+",Ne,Be,Fe";
			ALG=ALG+"match1";
			String q = "SELECT * FROM uprn_v2.uprn_main where node='X5' and post='"+tpost+"' ";
			q = q + "and street='"+tstreet+"' ";
			q = q + "and bno='"+tbno+"' ";
			q = q + "and build='"+tbuild+"' ";
			q = q + "and flat='"+tflat+"'";
			matches = setuprns("X5","","","","","",q,ALG,matchrec);
		}

		return matches;
	}

	public Integer matchall(String indrec, Integer adplural, String indprec) throws SQLException
	{
		String matchrec = "Pe,Ne,Be,Fe";
		String ALG = "1-match";

		System.out.println(indrec);

		Integer matched = 0;
		String q = "";

		// 1
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
				q = "select * from uprn_v2.uprn_main where indrec ='"+indprec+"' and node='X';";
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