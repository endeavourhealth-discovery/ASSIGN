package org.endeavourhealth.uprnAlgorithm.common;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.mysql.cj.xdevapi.PreparableStatement;
import com.sun.deploy.security.SelectableSecurityManager;
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

	public static Integer isflat(String text, Repository repository) throws SQLException {
		Integer n = 0;

		// $p(text," ",2)'?1n.n.e
		if (Piece(text," ",1,1).equals("tower") && RegEx(Piece(text, " ",2, 2),"^(\\d\\w+)").equals(0)) return 0;

		if (repository.QueryFlat(text).equals(1)) { n =1; }

		return n;
	}

	public static String flat(String text, Repository repository) throws SQLException {
		Integer i;

		if (text.equals("flat")) {return "";}
		if (text.isEmpty()) {return "";}

		//^(no )\w <= ?1"no"1" ".e
		if (RegEx(text, "^(no )\\w").equals(1)) {
			text = Piece(text, " ",2, 10);
		}

		// ?1"flat"1n.n <= ^(flat)\d+$
		if (RegEx(text, "^(flat)\\d+$").equals(1)) {
			return Piece(text, "flat", 2, 10);
		}

		return repository.flat(text);
	}

	public static Integer isroad(String text, Repository repository) throws SQLException {
		Integer road = 0;
		Integer i;

		for (i = 1; i <= CountPieces(text, " "); i++) {
			String word = Piece(text, " ",i, i);
			if (word.isEmpty()) continue;
			road = repository.isroad(word);
		}

		return road;
	}

	public static Integer isno(String word)
	{
		/*
		if word?1n.n q 1 <= ^[0-9]+$
		if word?1n.n1l q 1 <= ^[0-9][a-z]
		if word?1n.n1"-"1n.n q 1 <= ^[0-9]+(-)[0-9]+$
		if word?1n.n1l1"-"1n.n1l q 1 <= ^[0-9]+[a-z](-)[0-9]+[a-z]
		*/

        if (RegEx(word, "^[0-9]+$").equals(1)) return 1;
        if (RegEx(word, "^[0-9][a-z]").equals(1)) return 1;
        if (RegEx(word, "^[0-9]+(-)[0-9]+$").equals(1)) return 1;
        if (RegEx(word, "^[0-9]+[a-z](-)[0-9]+[a-z]").equals(1)) return 1;

		return 0;
	}

	// Strips off care of
	public static String co(String number)
    {
        if (Piece(number, "-", 1, 1).replaceAll("-","").equals("co")) {
            if (CountPieces(number, " ") > 1) {
                number = Piece(number, " ",2, 10);
            }
        }
        return number;
    }

    // mumps code returns adflat and adbuild by reference
	public static void flatbld(String adflat, String adbuild)
    {
        // is it a flat or number and if so what piece is the rest?
        adbuild = co(adbuild);
        if (adbuild.contains("flat-")) { adbuild = adbuild.replace("-"," ");}

        // Welsh 'y'
        // f36

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
									adbuild = Piece(adbuild," ",1,CountPieces(adbuild," ")-2);
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
				if (RegEx(adstreet,"^[a-z]+").equals(1)) {
					for (i = 1; i <= CountPieces(adstreet," "); i++) {
						if (!adbuild.isEmpty()) {break;}
						// ?1n.n.l <= \\d\\w
						if (RegEx(Piece(adstreet, " ", i, i),"\\d\\w").equals(1)) {
							if (RegEx(Piece(adstreet, " ", i+1, i+1),"\\d\\w").equals(1)) {
								adbuild = Piece(adstreet," ",1,i);
								adstreet = Piece(adstreet, " ", i+1, 20);
								continue;
							}
							adbuild = Piece(adstreet, " ", 1, i-1);
							adstreet = Piece(adstreet, " ",i, 20);
							Integer z = CountPieces(adbuild, " ");
							String last = Piece(adbuild," ", z, z);
							if (last.contains("-")) {
								if (RegEx(last,"\\d(-)$").equals(1)) {
									adstreet = last+adstreet;
									z = CountPieces(adbuild," ");
									adbuild = Piece(adbuild, " ",1, z-1);
								}
							}
						}
					}
				}
			}
		}

		// f10
		if (addlines.equals(2)) {
			adbuild = Piece(address, d, 1, 1);
			adstreet = Piece(address, d, 2, 2);
			if (RegEx(adstreet,"\\d").equals(1) && !adbuild.isEmpty()) {
				adstreet = adstreet + " " + adbuild;
				adbuild = "";
			}
		}

		// f11
		if (addlines.equals(3)) {
			adbuild = Piece(address, d, 1, 1);
			adstreet = Piece(address, d, 2, 2);
			adloc = Piece(address, d, 3, 3);
		}

		// f12
		if (addlines.equals(4)) {
			adbuild = Piece(address, d, 1, 1);
			adstreet = Piece(address, d, 2, 2);
			adeploc = Piece(address, d, 3, 3);
			adloc = Piece(address, d, 4, 4);
		}

		// f13
		if (addlines.equals(5)) {
			adbuild = Piece(address, d, 1, 1);
			adepth = Piece(address, d, 2, 2);
			adstreet = Piece(address, d, 3, 3);
			adeploc = Piece(address, d, 4, 4);
			adloc = Piece(address, d, 5, 5);
		}

		// f14
		if (addlines.equals(6)) {
			adbuild = Piece(address, d, 1,1) + " " + Piece(address, d, 2,2);
			adepth = Piece(address, d, 3, 3);
			adstreet = Piece(address, d, 4, 4);
			adeploc = Piece(address, d, 5, 5);
			adloc = Piece(address, d, 6, 6);
		}

		// f15
		if (addlines.equals(7)) {
			adbuild = Piece(address, d, 1, 1) +" "+ Piece(address, d, 2, 2);
			adepth = Piece(address, d, 3, 3);
			adstreet = Piece(address, d, 4, 4) +" "+ Piece(address, d, 5, 5);
			adeploc = Piece(address, d, 6, 6);
			adloc = Piece(address, d, 7, 7);
		}

		// f16
		adbuild.trim(); adstreet.trim(); adepth.trim(); adeploc.trim(); adloc.trim();

		Hashtable<String, String> hAddress = new Hashtable<String, String>();
		String orig = post +" "+ flat(adflat, repository) +" "+ flat(adbuild, repository) +" "+ adepth +" "+ adstreet +" "+ adeploc;
		orig.trim();
		orig.replace("  "," ");

		// hAddress is what we should return
		hAddress.put("original", orig);

		// f17
		for (;;) {
			if (!adeploc.isEmpty()) {
				if (isroad(adeploc, repository).equals(1) && isroad(adstreet, repository).equals(0)) {
					// ?1"no"1" "1n.n <= ^(no )\d+$
					if (RegEx(adstreet, "^(no )\\d+$").equals(1)) {
						adstreet = Piece(adstreet, " ", 2, 2) + " " + adeploc;
						adeploc = "";
					}

                    // adstreet?1n.n!(adstreet?1n.n1l)
                    // \d+$ <= ?1n.n ! ^(\d+\w)$
                    if (!adbuild.isEmpty() && (RegEx(adstreet, "\\d+$").equals(1) || RegEx(adstreet, "^(\\d+\\w)$").equals(1))) {
                        adstreet = adstreet + " " + adeploc;
                        adeploc = "";
                    }

					//f18
					// if adstreet?1l.e, adeploc?1n.n."-".n1" "1l.e
					// ^([a-z]\w+)$ , ^(\d+(-)\d+( )[a-z]\w+)
                    // implemented OR | for stratford one~flat 305~1 international way~london south~e201gs
                    // 1 international way
					if (RegEx(adstreet, "^([a-z]\\w+)").equals(1) && (RegEx(adeploc, "^(\\d+(-)\\d+|\\d+( )[a-z]\\w+)").equals(1))) {
						if (adstreet.contains("flat")) {
							adbuild = adstreet + " " + adbuild;
							adstreet = adeploc;
							adeploc = "";
						}
						// f19
						else {
							adbuild = adbuild + " " + adstreet;
							adstreet = adeploc;
							adeploc = "";
						}
						break;
					}
					// f20
					if (!adbuild.isEmpty()) {
						n = repository.floor(Piece(adstreet, " ", 1, 1));
						if (n.equals(1)) {
							adbuild = adbuild + " " + adstreet;
							adstreet = "";
							break;
						}
					}
					// f21
					if (!adepth.isEmpty()) {
						adstreet = adepth + " " + adbuild;
						adepth = "";
						adeploc = "";
					}
					// f22
					else {
						adstreet = adeploc;
					}
					if (isflat(adstreet, repository).equals(1)) {
						adbuild = adstreet + " " + adbuild;
						adstreet = adepth + " " + adeploc;
						adepth = "";
						adeploc = "";
						break;
					}
				}
			}
			break; // make sure we exit infinite loop
		}

		System.out.println(">>>> test");

		// Location is street, street is building
		for (;;) {
			if (!adloc.isEmpty() && !adstreet.isEmpty()) {
				if (isroad(adloc, repository).equals(1) && isroad(adstreet, repository).equals(0)) {
					// adloc?1n.n1" "1l.e
					// ^(\d+( )[a-z]\w+)$
					// f24
					if (RegEx(adloc, "^(\\d+( )[a-z]\\w+)$").equals(1)) {
						// f25
						if (RegEx(adstreet, "^\\d+$").equals(1)) {
							// ?1l.l.e
							// ^[a-z]+\w$
							if (RegEx(adbuild, "^[a-z]+\\w$").equals(1)) {
								adbuild = adstreet + " " + adbuild;
								adstreet = adloc;
								adloc = "";
							}
						}
						break;
					}
					// f26
					// i adstreet?1n.n!(adstreet?1n.n1"-"1n.n)!(adstreet?1n.n1l)
					if (RegEx(adstreet, "^[0-9]+$").equals(1) || RegEx(adstreet, "^[0-9]+(-)[0-9]+$").equals(1) && RegEx(adstreet, "^[0-9]+[a-z]$").equals(1)) {
						adstreet = adstreet + " " + adloc;
						adloc = "";
						break;
					}
					// f27
					if (adflat.isEmpty()) {
						adflat = adbuild;
						// f28
						if (!adstreet.isEmpty()) {
							adbuild = adstreet;
							break;
						} else {
							// ?1n.n.l1" "2l.e
							// ^[0-9]+[a-z]( )[a-z][a-z]
							// f29
							if (RegEx(adflat, "^[0-9]+[a-z]( )[a-z][a-z]").equals(1)) {
								adbuild = Piece(adflat, " ", 2, 20);
								adflat = Piece(adflat, " ", 1, 1);
								adstreet = adloc;
								adloc = "";
								break;
							}
						}
					}
				}
				adbuild = adbuild +" "+adstreet;
				adstreet = adloc;
				adloc = "";
			}
			break;
		}

		//Only one  line, likely to be street But may be flat and building
		//Location is actually number and street
		//?1n.n.l1" "1l.e
		//f30
		if (RegEx(adloc,"^[0-9]+[a-z]( )[a-z]").equals(1)) {
			if (RegEx(adstreet, "^[0-9]+[a-z]( )").equals(0)) {
				adbuild = adbuild +" "+adstreet;
				adstreet = adloc;
				adloc = "";
			}
		}

		// Street starts with flat number so swap
		// May or may not contain building
		// f31
		for (;;) {
			if (isflat(adstreet, repository).equals(1)) {
			    // f32
				if (isroad(adstreet, repository).equals(0)) {
					String xbuild = adbuild;
					adbuild = adstreet;
					adstreet = xbuild;
					break;
				}
				// f33
				else
				{
					if (isno(Piece(adstreet, " ", 3, 3)).equals(1)) {
					    // f34
					    if (!adbuild.isEmpty()) {
					        adbuild = Piece(adstreet, " ", 1, 2)+" "+adbuild;
                        }
					    // f35
					    else {
					        adbuild = Piece(adstreet, " ", 1, 2);
					        adstreet = Piece(adstreet, " ", 3, 20);
                        }
                    }
				}
			}
			break;
		}

		// f35a Brackets
        if (adbuild.contains("(")) {
            for (;;) {
                if (adbuild.contains("(l)")) break;
                adbuild = adbuild.replace("("," ");
                adbuild = adbuild.replace(")"," ");
                adbuild = adbuild.replaceAll("  "," ");
            }
        }

        // Ordinary flat building various formats, split it up
        if (adflat.isEmpty()) {

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