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

		String regex = "^[a-z]{1,2}[0-9]{1,2}[a-z]?([0-9][a-x]{1,2})?$";
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

	private String correct(String text) throws SQLException
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
			//String correct = QueryUPRNSHash(correctHash, word);
			String correct = "";
			if (!correct.isEmpty()) {
				data[i] = correct;
			}
		}

		text = "";
		for (i=0; i < data.length; i++) {text = text + data[i] + " ";};
		// remove trailing space
		text = text.trim();


		text.replace(" & "," and ");

		return text;
	}

	public static String spelchk(String address, Repository repository) throws SQLException
	{
		address = address.replace(" to - ","-");

		Integer l = CountPieces(address,"~")-1;
		Integer part; Integer wordno;
		for (part = 0; part <= l; part++) {
			String field = Piece(address,"~", part, part);
			System.out.println(field);
			Integer zl = CountPieces(field," ");
			for (wordno = 0; wordno<zl; wordno++) {
				String word = Piece(field, " ", wordno, wordno);
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
						continue;
					}
				}

			}
		}
		return "";
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
			System.out.println("test");
			ISFLAT=1;
		}

		// test Piece method
		System.out.println(Piece(address,"~",3,3));

		String orig = "a~b~c~d~e~f";
		String tester = setSingle$Piece(orig, "~", "xxxx", 4);
		System.out.println(tester);

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