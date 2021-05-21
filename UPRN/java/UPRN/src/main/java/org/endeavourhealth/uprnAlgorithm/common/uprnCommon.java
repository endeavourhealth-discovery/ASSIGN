package org.endeavourhealth.uprnAlgorithm.common;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.endeavourhealth.uprnAlgorithm.repository.Repository;

public class uprnCommon {

	public static void TestCommon()
	{
		System.out.println("test");
	}

	public static Integer validp(String post)
	{
		//String regex = "^[a-z]{1,2}[0-9R][0-9a-z][0-9][abd-hjlnp-uw-z]{2}$";

		String regex = "^[a-z]{1,2}[0-9]{1,2}[a-z]?([0-9][a-z]{1,2})?$";
		Pattern pattern = Pattern.compile(regex);

		Matcher matcher = pattern.matcher(post);
		System.out.println(matcher.matches());

		if (!matcher.matches()) {
			return 0;
		}
		return 1;
	}

	public static String area(String post) {
		Integer z = post.length();
		for (Integer i=0; i <z; i++) {
			if (Character.isDigit(post.charAt(i))) {
				return post.substring(0, i);
			}
		}
		return "";
	}


	public static boolean indexInBound(String[] data, int index){
		return data != null && index >= 0 && index < data.length;
	}

	public static String Piece(String str, String del, Integer from, Integer to)
	{
		Integer i;
		String p[] = str.split(del,-1);
		String z = "";

		from = from -1; to = to -1;

		Integer zdel = 0;
		if (to > from) {zdel = 1;}

		for (i = from; i <= to; i++) {
			if (indexInBound(p, i)) {
				z = z + p[i];
				if (zdel.equals(1)) {z =z + del;}
			}
		}

		if (zdel.equals((1)) && !z.isEmpty()) {
			// remove delimeter
			z = z.substring(0, z.length()-1);
		}

		return z;
	}

	public static Integer CountPieces(String str, String del)
	{
		String[] split = str.split(del);
		return split.length;
	}

	public static String setSingle$Piece(String orig, String d, String data, Integer pce)
	{
		String znew = "";
		String p[] = orig.split(d,-1);
		pce = pce -1;
		p[pce] = data;
		int i;
		for (i = 0; i <= p.length-1; i++) {
			znew = znew + p[i] + d;
		}

		znew = znew.substring(0, znew.length()-1);

		return znew;
	}

	private static String correct(String text, Repository repository) throws SQLException
	{

		if (text.isEmpty()) return text;

		text = text.replace("lll","ll");

		if (Piece(text," ",1,2).equals("known as")) {
			text = Piece(text," ",3,20);
		}

		String[] data = text.split(" ",-1);
		Integer i;
		for (i=0; i < data.length; i++) {
			String word = data[i];
			String correct = repository.QueryDictionary("CORRECT", word);
			if (!correct.isEmpty()) {
				if (word.equals("st")) {
					String saint = "st "+Piece(text," ",i+1,i+1);
					// $Data(^UPRNX("X.STR",saint))
					Integer in = repository.XSTR(saint, 0);
					if (in.equals(1)) {continue;}
					// $Order(^UPRNX("X.STR",saint))
					in = repository.XSTR(saint,1);
					if (in.equals(1)) {continue;}
					text = setSingle$Piece(text," ","street",i);
					continue;
				}
				text = setSingle$Piece(text," ",correct,i);
			}
		}

		text.replace(" & "," and ");

		return text;
	}

	public static String spelchk(String address, Repository repository) throws SQLException
	{
		address = address.replace(" to - ","-");

		Integer l = CountPieces(address,"~")-1;
		Integer part; Integer wordno;
		for (part = 1; part <= l; part++) {
			String field = Piece(address,"~", part, part);
			System.out.println(field);
			Integer zl = CountPieces(field," ");
			String word = "";
			for (wordno = 1; wordno <= zl; wordno++) {
				word = Piece(field, " ", wordno, wordno);
				if (word.equals("st")) {
					String saint = "st " + Piece(field," ",wordno+1,wordno+1);
					if (saint.equals("st ")) {
						word = "street";
						field = setSingle$Piece(field, " ", word, wordno);
						continue;
					}
					// $Data(^UPRNX("X.STR",saint))
					Integer in = repository.XSTR(saint, 0);
					if (in.equals(1)) {continue;}
					// $Order(^UPRNX("X.STR",saint))
					in = repository.XSTR(saint,1);
					if (in.equals(1)) {continue;}
					word = "street";
					field = setSingle$Piece(field, " ", word, wordno);
				}
				if (word.equals("p")) {
					if (Piece(field," ",wordno+1,wordno+1).equals("h")) {
						word = "public house";
						field = setSingle$Piece(field," ","public",wordno);
						field = setSingle$Piece(field," ","house", wordno+1);
					}
				}
				word = correct(word, repository);
				setSingle$Piece(field," ",word,wordno);
			}
			setSingle$Piece(address,"~",field,part);
		}
		return address;
	}

	public static Integer RegEx(String data, String regex)
	{
		Integer n = 0;

		Pattern pattern = Pattern.compile(regex);
		Matcher matcher = pattern.matcher(data);

		if (matcher.lookingAt()) {n=1;}

		return n;
	}

	// format^UPRNA
	public static String format(Repository repository, String adrec) throws SQLException {
		String d = "~";

		String adflat = "";
		String adbuild = "";
		String adbno = "";
		String adepth = "";
		String adeploc = "";
		String adstreet = "";
		String adloc = "";
		String post = "";
		String tempadd = "";

		String address = adrec.toLowerCase();
		Integer ISFLAT = 0;

		String regex = "(flat )\\d( )\\w"; // ?1"flat"1" "1n.n.l1" ".e
		Pattern pattern = Pattern.compile(regex);

		Matcher matcher = pattern.matcher(address);
		if (matcher.lookingAt()) {
			System.out.println("its a flat!");
			ISFLAT=1;
		}

		// test Piece method
		//System.out.println(Piece(address,"~",3,3));

		//String orig = "a~b~c~d~e~f";
		//String tester = setSingle$Piece(orig, "~", "xxxx", 4);
		//System.out.println(tester);

		if (address.contains(".")) {
			int from=0; int to = CountPieces(address," ")-1;
			int i;

			regex = "\\d([.])\\d"; // ?1n.n1"."1n.n.e
			pattern = Pattern.compile(regex);

			for (i = from; i <= to; i++) {
				String word = Piece(address, " ", i, i);
				if (word.contains(".")) {
					matcher = pattern.matcher(word);
					if (matcher.lookingAt()) {
						System.out.println(word);
						word = word.replace(".","-");
						address = setSingle$Piece(address," ",word,i);
					}
				}
			}
		}

		address = address.replaceAll("\\."," ");
		address = address.replaceAll("\\*"," ");
		address = address.replaceAll("\\s{2}", " ").trim();
		address = address.replaceAll("~\\s{1}","~").trim();

		address = spelchk(address, repository);

		// get the post code from the last field
		Integer length = CountPieces(address, d);
		post = Piece(address,d,length,length).toLowerCase();
		post = post.replace(" ","");

		// remove london,middlesex
		//f2
		int i;
		for (i = 1; i <= length-1; i++) {
			String part = Piece(address,d,i,i);
			if (part.isEmpty()) continue;
			//if (part.equals("london")) continue;
			String data = repository.QueryDictionary("CITY",part);
			if (!data.isEmpty()) {continue;}
			data = repository.QueryDictionary("COUNTY",part);
			if (!data.isEmpty()) {continue;}

			Integer zc = CountPieces(part," ");
			String z = Piece(part, " ", zc, zc);

			data = repository.QueryDictionary("COUNTY",z);
			if (!data.isEmpty()) {
				zc = CountPieces(part," ")-1;
				part = Piece(part," ",1,zc);
			}

			data = repository.QueryDictionary("CITY",z);
			if (!data.isEmpty()) {
				zc = CountPieces(part, " ") - 1;
				part = Piece(part, " ", 1, zc);
			}

			if (tempadd.isEmpty()) {tempadd=part;}
			else
			{
				tempadd = tempadd+"~"+part;
			}
		}

		address = tempadd + "~" + post;

		Integer addlines = CountPieces(address,"~")-1;

		// too many address lines may be duplicate post code
		//f3
		//flat 25~33 heathcote grove~chingford~e4 6rz~e46rz
		if (addlines > 2) {
			for (i = 2; i <= addlines; i++) {
				String part = Piece(address, d, i, i).replace(" ","");
				// query the ABP covering indexes to check if address field is a post code?
				Integer in = repository.QueryIndexes(part, "post");
				if (in.equals(1)) {
					post = Piece(address,d,i,i).replace(" ","");
					addlines = i-1;
					address = Piece(address,d,1,addlines+1);
				}
			}
		}

		// may have too many address lines number is alone in field 1
		//f4
		//92,summit estate,portland avenue,stamford hill,n166ea
		if (addlines > 2) {
			// ^[0-9-(0-9)]+$
			// ^[a-z]+
			regex = "^[0-9-(0-9)]+$";
			pattern = Pattern.compile(regex);
			Matcher matcher1 = pattern.matcher(Piece(address, d, 1, 1));

			regex = "^[a-z]+";
			pattern = Pattern.compile(regex);
			Matcher matcher2 = pattern.matcher(Piece(address, d, 2, 2));

			if (matcher1.lookingAt() && matcher2.lookingAt()) {
				String n = Piece(address, d, 1, 1) +" "+ Piece(address, d, 2, 2);
				address = setSingle$Piece(address, d, n, 1);
				address = Piece(address, d, 1, 1) +d+ Piece(address, d, 3, 10);
				addlines = addlines -1;
			}
		}

		// Still too many, number s alone in field 2
		//f5
		//room 6 house,27,p o box 1558,n165jj
		if (addlines > 2) {
			// ^[0-9]+$
			// ^[a-z]+
			regex = "^[0-9]+$";
			pattern = Pattern.compile(regex);
			Matcher matcher1 = pattern.matcher(Piece(address, d, 2, 2));

			regex = "^[a-z]+";
			pattern = Pattern.compile(regex);
			Matcher matcher2 = pattern.matcher(Piece(address, d, 3, 3));

			if (matcher1.lookingAt() && matcher2.lookingAt()) {
				String n = Piece(address, d, 2, 2) +" "+ Piece(address, d, 3, 3);
				address = setSingle$Piece(address, d, n, 2);
				address = Piece(address, d, 1, 2) + d + Piece(address, d, 4, 10);
				addlines = addlines -1;
			}
		}

		// Duplicate street?
		//f6
		//pentland house,30 stamford hill,stamford hill,n166xz
		if (addlines > 2) {
			if (Piece(Piece(address, d, 2, 2)," ",2,10).equals(Piece(address, d, 3, 3))) {
				address = Piece(address, d, 1, 2) +"~"+ Piece(address, d, 4, 10);
				addlines = addlines - 1;
			}
		}

		//flat and building is line 1, number and street is line 2
		//f8
		//11a northfield road,n165rl
		Integer n = 0;
		if (addlines.equals(1)) {
			adbuild = "";
			adstreet = Piece(address, d, 1, 1);
			Integer strfound = 0;
			if (CountPieces(adstreet, " ")>1) {
				Integer lenstr = CountPieces(adstreet, " ");
				for (i = 1; i <= lenstr; i++) {
					if (repository.XSTR(Piece(adstreet," ",i,lenstr),0).equals(1)) {
						strfound = 1;
						// ?1n.n.l
						if (RegEx(Piece(adstreet," ",i-1,i-1), "\\d\\w").equals(1)) {
							if (ISFLAT.equals(1)) {
								adflat = Piece(adstreet," ", 1, 2);
								adstreet = Piece(adstreet, " ", 3, CountPieces(adstreet," "));
							}
							adbuild = Piece(adstreet," ", 1, i-2);
							adstreet = Piece(adstreet," ",i-1,lenstr);
							String last = Piece(adbuild," ",1,CountPieces(adbuild," ")-1);
							if (last.contains("-")) {
								// \d(-)$ = ?1n.n1"-"
								if (RegEx(last,"\\d(-)$").equals(1)) {
									adstreet = last + adstreet;
									//adbuild = Piece(adbuild," ")
								}
							}
						}
						else
						{
							adbuild = Piece(adstreet, " ", 1, i-1);
							adstreet = Piece(adstreet," ", 1, CountPieces(adbuild," ")-2);
						}
					}
				}
				// f9
			}
		}

		return "";
	}

	public static Integer inpost(Repository repository, String area, String qpost) throws SQLException {
		Integer in = 0;
		in = repository.inpost(area, qpost);
		return in;
	}

	public static Hashtable<String, String> ADRQUAL(String rec, String country)
	{

		Hashtable<String, String> hashTable =
				new Hashtable<String, String>();

		rec = rec.toLowerCase();
		if (!rec.contains("~")) {
			hashTable.put("INVALID","Null address lines");
			return hashTable;
		}

		rec = rec.replaceAll("[{}]","");

		Integer count = rec.split("~",-1).length;
		String data[] = rec.split("~",-1);

		String post =  data[count-1];
		post = post.replaceAll("\\s","");

		Integer i = validp(post);
		if (i.equals(0)) {
			hashTable.put("INVALID","Invalid post code");
			return hashTable;
		}

		return hashTable;
	}
}