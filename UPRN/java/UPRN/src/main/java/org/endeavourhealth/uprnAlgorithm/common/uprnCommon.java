package org.endeavourhealth.uprnAlgorithm.common;

import java.io.FileWriter;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.mysql.cj.util.StringUtils;
import com.mysql.cj.xdevapi.PreparableStatement;
import com.sun.corba.se.impl.orbutil.RepositoryIdStrings;
import com.sun.deploy.security.SelectableSecurityManager;
import com.sun.org.apache.regexp.internal.REProgram;
import com.sun.xml.internal.ws.policy.privateutil.PolicyUtils;
import javafx.scene.input.PickResult;
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
		//System.out.println(matcher.matches());

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
			z = z.substring(0, z.length()-del.length());
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
					text = setSingle$Piece(text," ","street",i+1);
					continue;
				}
				text = setSingle$Piece(text," ",correct,i+1);
			}
		}

		text.replace(" & "," and ");

		return text;
	}

	public static String spelchk(String address, Repository repository) throws SQLException
	{
		if (address.contains(" to - ")) {
			address = address.replace(" to - ", "-");
		}

		Integer l = CountPieces(address,"~")-1;
		Integer part; Integer wordno;
		for (part = 1; part <= l; part++) {
			String field = Piece(address,"~", part, part);
			//System.out.println(field);
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
				field = setSingle$Piece(field," ",word,wordno);
			}
			address = setSingle$Piece(address,"~",field,part);
		}
		return address;
	}

	public static Integer RegEx(String data, String regex)
	{
		Integer n = 0; Integer n2 = 0; Integer n3= 0;

		Pattern pattern = Pattern.compile(regex);
		Matcher matcher = pattern.matcher(data);

		if (matcher.lookingAt()) {n=1;}

		if (matcher.matches()) {n2=1;}
		if (matcher.find()) {n3=1;}


		return n;
	}

	public static Integer isflat(String text, Repository repository) throws SQLException {
		Integer n = 0;

		// $p(text," ",2)'?1n.n.e
		//if (Piece(text," ",1,1).equals("tower") && RegEx(Piece(text, " ",2, 2),"^(\\d\\w+)").equals(0)) return 0;
		//if (repository.QueryFlat(text).equals(1)) { n =1; }

        n = repository.isflat(text);

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

    public static String extractNumber(String str)
    {
        String sb = "";
        for(char c : str.toCharArray()) {
            if (Character.isDigit(c)) {
                sb = sb + c;
            }
            else {
                break;
            }
        }
        return sb;
    }

	public static String f17(String adeploc, String adstreet, String adbuild, String adepth, Repository repository) throws SQLException
	{
		if (!adeploc.isEmpty()) {
			if (isroad(adeploc, repository).equals(1) && isroad(adstreet, repository).equals(0)) {
				if (RegEx(adstreet, "^(no )\\d+$").equals(1)) {
					adstreet = Piece(adstreet, " ", 2, 2) + " " + adeploc;
					adeploc = "";
				}
				if (!adbuild.isEmpty() && (RegEx(adstreet, "\\d+$").equals(1) || RegEx(adstreet, "^(\\d+\\w)$").equals(1))) {
					adstreet = adstreet + " " + adeploc;
					adeploc = "";
				}
				if (RegEx(adstreet, "^([a-z]\\w+)").equals(1) && (RegEx(adeploc, "^(\\d+(-)\\d+|\\d+( )[a-z]\\w+)").equals(1))) {
					if (adstreet.contains("flat")) {
						adbuild = adstreet + " " + adbuild;
						adstreet = adeploc;
						adeploc = "";
					}
					else {
						adbuild = adbuild + " " + adstreet;
						adstreet = adeploc;
						adeploc = "";
					}
					return adeploc +"~"+ adstreet +"~"+ adbuild +"~"+ adepth;
				}
				if (!adbuild.isEmpty()) {
					Integer n = repository.floor(Piece(adstreet, " ", 1, 1));
					if (n.equals(1)) {
						adbuild = adbuild + " " + adstreet;
						adstreet = "";
						if (!adepth.isEmpty()) {
							adstreet = adepth + " " + adeploc;
							adepth = ""; adeploc = "";
						}
						else {
							adstreet = adeploc;
						}
						return adeploc +"~"+ adstreet +"~"+ adbuild +"~"+ adepth;
					}
					if (isflat(adstreet, repository).equals(1)) {
						adbuild = adstreet + " " + adbuild;
						adstreet = adepth + " " + adeploc;
						adepth = ""; adeploc = "";
					}
				}
			}
		}
		return adeploc +"~"+ adstreet +"~"+ adbuild +"~"+ adepth;
	}

	// Location is street, street is building
	public static String f23(String adloc, String adstreet, String adbuild, String adflat, Repository repository) throws SQLException
	{
		if (!adloc.isEmpty() && !adstreet.isEmpty()) {
			if (isroad(adloc, repository).equals(1) && isroad(adstreet, repository).equals(0)) {
				// adloc?1n.n1" "1l.e
				// ^(\d+( )[a-z]\w+)$
				// f24
				if (RegEx(adloc, "^(\\d+( )[a-z]\\w+)$").equals(1)) {
					// f25
					if (RegEx(adstreet, "^\\d+$").equals(1)) {
						if (RegEx(adbuild, "^[a-z]+\\w$").equals(1)) {
							adbuild = adstreet + " " + adbuild;
							adstreet = adloc;
							adloc = "";
						}
					}
					return adloc+"~"+adstreet+"~"+adbuild+"~"+adflat;
				}
				// f26
				if (RegEx(adstreet, "^[0-9]+$").equals(1) || RegEx(adstreet, "^[0-9]+(-)[0-9]+$").equals(1) || RegEx(adstreet, "^[0-9]+([a-z]|[a-z]+)$").equals(1)) {
					adstreet = adstreet + " " + adloc;
					adloc = "";
					return adloc+"~"+adstreet+"~"+adbuild+"~"+adflat;
				}
				// f27
				if (adflat.isEmpty()) {
					adflat = adbuild;
					if (!adstreet.isEmpty()) {
						adbuild = adstreet;
					}
					else
					{
						if (RegEx(adflat, "^[0-9]+[a-z]( )[a-z][a-z]").equals(1)) {
							adbuild = Piece(adflat, " ", 2, 20);
							adflat = Piece(adflat, " ", 1, 1);
							adstreet = adloc;
							adloc = "";
						}
					}
					adstreet = adloc;
					adloc = "";
					return adloc+"~"+adstreet+"~"+adbuild+"~"+adflat;
				}
				adbuild = adbuild +" "+adstreet;
				adstreet = adloc;
				adloc = "";
			}
		}
		return adloc+"~"+adstreet+"~"+adbuild+"~"+adflat;
	}

	public static String flatbld(String adflat, String adbuild, Repository repository) throws SQLException {
		// is it a flat or number and if so what piece is the rest?
		adbuild = co(adbuild);
		if (adbuild.contains("flat-")) {
			adbuild = adbuild.replace("-", " ");
		}

		// Welsh 'y'
		// f36
		// ?1n.n1" "1"y"1" "1l.e <= ^[0-9]( )(y)( )[a-z]/w+
		if (RegEx(adbuild, "^[0-9]( )(y)( )[a-z]/w+").equals(1)) {
			adflat = extractNumber(adbuild);
			adbuild = "y" + Piece(adbuild, " ", 3, 10);
		}

		// f37
		for (;;) {
			if (isflat(adbuild, repository).equals(1)) {
				adflat = Piece(adbuild, " ", 1, 2);
				adbuild = Piece(adbuild, " ", 3, 10);
				// adbuild?1"floor"1" "1n.n.l1" ".e
				// ^(floor)( )[0-9]+[a-z]( )\w
				if (RegEx(adbuild, "^(floor)( )[0-9]+[a-z]( )\\w").equals(1)) {
					adflat = adflat + " " + Piece(adbuild, " ", 1, 2);
					adbuild = Piece(adbuild, " ", 3, 20);
				}

				// f38
				if (repository.QueryFlat(adflat).equals(1)) {
					adflat = adbuild;
					adbuild = "";
				}

				// f39
				if (repository.VERTICALS(adbuild).equals(1)) {
					if (adflat.isEmpty()) {
						adflat = adbuild;
					} else {
						adflat = adflat + " " + adbuild;
					}
					adbuild = "";
				}

				// f40
				if (adbuild.equals("floors") | (adbuild.equals("floor"))) {
					adflat = adflat + " " + adbuild;
					adbuild = "";
					break;
				}

				// f41
				if (RegEx(adbuild, "^([a-z]( )\\w+)").equals(1)) {
					adflat = adflat + Piece(adbuild, " ", 1, 1);
					adbuild = Piece(adbuild, " ", 2, 20);
				}

				// f42
				// ?1n.n.l1" "1l.e
				// ^[0-9]+[a-z]( )[a-z]\w+
				if (RegEx(adbuild, "[0-9]+[a-z]( )[a-z]\\w+").equals(0)) {
					if (repository.floor(Piece(adbuild, " ", 1, 1)).equals(1)) {
						adflat = adflat + " " + Piece(adbuild, " ", 1, 1);
						adbuild = Piece(adbuild, " ", 2, 10);
					}
				}
				break;
			}
			break;
		}

		// f43
		if (repository.VERTICALS(adbuild).equals(1)) {
			// *** TO DO return adflat and adbuild
			adflat = adbuild;
			adbuild = "";
			return adflat+"~"+adbuild;
		}

		// f44 2nd floor flat etc
		if (!adbuild.isEmpty()) {
			// ** TO DO
			// s address("obuild")=adbuild <= needs to be part of has table
			adbuild = setSingle$Piece(adbuild, " ", correct(Piece(adbuild, " ", 1, 1), repository), 1);
		}

		// f45 18pondo road
		// ?1n.n2l.l1" "2l.e
		// ^[0-9]+[a-z][a-z]|[a-z](" ")[a-z][a-z]\w
		if (RegEx(adbuild, "^[0-9]+[a-z][a-z]|[a-z]( )[a-z][a-z]\\w").equals(1)) {
			Integer z = adbuild.length();
			for (Integer i = 0; i < z; i++) {
				if (!Character.isDigit(adbuild.charAt(i))) {
					break;
				}
				adflat = adflat + adbuild.substring(i, i);
			}
			adbuild = Piece(adbuild, adflat, 2, 10);
			return adflat+"~"+adbuild;
		}

		// f46 19a
		// ?1n.n.l
		if (RegEx(adbuild, "^([0-9]+|[0-9]+[a-z]+)$").equals(1)) {
			adflat = adbuild;
			adbuild = "";
			return adflat+"~"+adbuild;
		}

		// f47
		// ?1n.n1" "1l
		if (RegEx(adbuild, "^[0-9]( )[a-z]$").equals(1)) {
			adflat = Piece(adbuild, " ", 1, 1) + Piece(adbuild, " ", 2, 2);
			adbuild = "";
			return adflat+"~"+adbuild;
		}

		// f48 19 a eagle house
		// 1n.n1" "1l1" ".e
		if (RegEx(adbuild, "^[0-9]( )[a-z]( )\\w").equals(1)) {
			adflat = Piece(adbuild, " ", 1, 1) + " " + Piece(adbuild, " ", 2, 2);
			adbuild = Piece(adbuild, " ", 3, 20);
			return adflat+"~"+adbuild;
		}

		// f49 18dn forth avenue
		// ?1n.n2l1" "1l.e
		// ^[0-9][a-z]{2}( )[a-z]\w
		if (RegEx(adbuild, "^[0-9][a-z]{2}( )[a-z]\\w").equals(1)) {
			adflat = Piece(adbuild, " ", 1, 1);
			adbuild = Piece(adbuild, " ", 2, 10);
			return adflat+"~"+adbuild;
		}

		// f50 19 eagle house or garden flat 1
		// ** TO DO
		// don't understand how garden flat 1 will return true for this regex?
		// ?1n.n.l1" "1l.e
		// ^[0-9][a-z]( )[a-z]\\w
		if (RegEx(adbuild, "^[0-9]+|[0-9]+[a-z]( )[a-z]\\w+").equals(1)) {
			adflat = Piece(adbuild, " ", 1, 1);
			adbuild = Piece(adbuild, " ", 2, 20);
			return adflat+"~"+adbuild;
		}

		// f51 19a-19c eagle house
		// ?1n.n.l1"-"1n.n.1" ".l.e
		// ^[0-9]+[a-z](-)[0-9]+\w( )[a-z]+\w
		if (RegEx(adbuild, "^[0-9]+[a-z](-)[0-9]+\\w( )[a-z]+\\w").equals(1)) {
			adflat = Piece(adbuild, " ", 1, 1);
			adbuild = Piece(adbuild, " ", 2, 20);
			return adflat+"~"+adbuild;
		}

		// f51a 73a-b
		// ?1n.n.l1"-"1l1" ".l.e
		// ^[0-9][a-z](-)[a-z]( )[a-z]\w+
		if (RegEx(adbuild, "^[0-9][a-z](-)[a-z]( )[a-z]\\w+").equals(1)) {
			adflat = Piece(adbuild, " ", 1, 1);
			adbuild = Piece(adbuild, " ", 2, 2);
		}

		// f52 19- eagle house
		// ?1n.n1"-"1" "1l.e
		// ^[0-9](-)( )[a-z]\w+
		if (RegEx(adbuild, "^[0-9](-)( )[a-z]\\w+").equals(1)) {
			adflat = Piece(adbuild, "-", 1, 1);
			adbuild = Piece(adbuild, " ", 2, 20);
			return adflat+"~"+adbuild;
		}

		//f53 first floor flat
		if (adbuild.contains(" flat") || adbuild.contains(" room") && !adflat.isEmpty()) {
			Integer flatfound = 0;
			int i;
			for (i = 1; i <= CountPieces(adbuild, " "); i++) {
				if (flatfound.equals(1)) break;
				String word = Piece(adbuild, " ", i, i);
				//f54
				if (word.equals("flat") || word.equals("room")) {
					flatfound = 1;
					String xbuild = Piece(adbuild, " ", i + 1, i + 1);
					//f55
					if (RegEx(xbuild, "^[0-9]+").equals(1) || RegEx(xbuild, "^[0-9][a-z]").equals(1)) {
						adflat = Piece(adbuild, " ", 1, 1);
						adbuild = Piece(adbuild, " ", i + 2, 20);
						if (adbuild.isEmpty() && repository.BUILDING(Piece(adflat, " ", i - 1, i - 1)).equals(1)) {
							adbuild = Piece(adbuild, " ", 1, i - 1);
							adflat = Piece(adflat, " ", i, 20);
						}
					} else {
						adflat = Piece(adbuild, " ", 1, i);
						adbuild = Piece(adbuild, " ", i + 1, 20);
					}
					break;
				}
			}
			return adflat+"~"+adbuild;
		}

		// f57 house 23
		// ?1"house"1" "1n.n.e
		// (house )[0-9]+/w+
		if (RegEx(adbuild, "(house )[0-9]+\\w+").equals(1)) {
			adflat = Piece(adbuild, " ", 2, 2);
			adbuild = Piece(adbuild, " ", 3, 20);
		}

		// f571 116 - 118
		// ?1n.n.l1" "1"-"1" "1n.n.l.e
		// ^([0-9]|[0-9]+\w+)( - )([0-9]|[0-9]+\w+)
		if (RegEx(adbuild, "^([0-9]|[0-9]+\\w+)( - )([0-9]|[0-9]+\\w+)").equals(1)) {
			adflat = Piece(adbuild, " ", 1, 1) +"-"+ Piece(adbuild, " ", 3, 3);
			adbuild = Piece(adbuild, " ", 4, 20);
			return adflat+"~"+adbuild;
		}

		//f58 12 -20 rosina street
		// ?1n.n1" "1"-"1n.n1" "1l.e
		// ^([0-9]+|[0-9]+\w+)( -)([0-9]+( )\w+|[0-9]+( )\w+)
		if (RegEx(adbuild, "^([0-9]+|[0-9]+\\w+)( -)([0-9]+( )\\w+|[0-9]+( )\\w+)").equals(1)) {
			adflat = Piece(adbuild, " ", 1, 1) +" "+ Piece(adbuild, " ", 2, 2);
			adbuild = Piece(adbuild, " ", 2, 10);
			return adflat+"~"+adbuild;
		}

		//f59 a cranberry lane
		// ?1l1" "1l.l1" "1l.e
		// ^[a-z]( )[a-z]+( )[a-z]+\w+
		if (RegEx(adbuild, "^[a-z]( )[a-z]+( )[a-z]+\\w+").equals(1)) {
			adflat = Piece(adbuild, " ", 1, 1);
			adbuild = Piece(adbuild, " ", 2, 10);
			return adflat+"~"+adbuild;
		}

		// f60 a203 carmine wharf
		// dlg02 carminw wharf
		// ?1l.l1n.n.1" "1l.e
		// ^[a-z]+[0-9]+( )[a-z]\w
		if (RegEx(adbuild, "^[a-z]+[0-9]+( )[a-z]\\w").equals(1)) {
			adflat = Piece(adbuild, " ", 1, 1);
			adbuild = Piece(adbuild, " ", 2, 10);
			return adflat+"~"+adbuild;
		}

		// f61 b202h unit building
		// ?1l1n.n.l1" "1l.e
		// ^[a-z][0-9]+[a-z]( )[a-z]\w
		if (RegEx(adbuild, "^[a-z][0-9]+[a-z]( )[a-z]\\w").equals(1)) {
			adflat = Piece(adbuild, " ", 1, 1);
			adbuild = Piece(adbuild, " ", 2, 20);
			return adflat+"~"+adbuild;
		}

		// f62 flaflat 10 mileset lodge
		if (adbuild.contains("flat")) {
			// f63
			// ?1n.n.l
			if (RegEx(Piece(adbuild, " ",2, 2),"^([0-9]+|[0-9]+[a-z]+)$").equals(1)) {
				adflat = "flat" + " " + Piece(adbuild, " ", 2, 2);
				adbuild = Piece(adbuild, " ", 3, 3);
			}
			// f64
			else {
				if (!adflat.isEmpty()) {
					adflat = "flat " + adflat;
					adbuild = Piece(adbuild, " ", 3, 20);
				}
			}
			return adflat+"~"+adbuild;
		}

		// f65 workshop 6
		// ?1.l1" "1n.n.l
		// ^[a-z]+( )([0-9]+|[a-z]+)
		if (!adflat.isEmpty() && RegEx(adbuild, "^[a-z]+( )([0-9]+)").equals(1)) {
			adflat=adbuild;
			adbuild = "";
		}

		return adflat+"~"+adbuild;
	}

	public static Integer numpos(String text)
    {
        Integer pos = 0;
        int i;
        for (i=1; i<CountPieces(text, " "); i++) {
            if (RegEx(Piece(text, " ", i, i),"^[0-9]+[a-z]$").equals(1)) { pos = i; }
        }
        return pos;
    }

    // do numstr(.adbno,.adstreet,.adflat,.adbuild)
	public static String numstr(String adbno, String adstreet, String adflat, String adbuild, String adloc, Repository repository) throws SQLException
	{
		// Reformat a variety of number and street patterns

		// f66
		// 38 & 40 arthur street
		// ?1n.n1" "1"&"1" "1n.n1" "1l.e
		// ^[0-9]+( & )[0-9]+( )([a-z]|[a-z]\w)
        if (RegEx(adstreet,"^[0-9]+( & )[0-9]+( )([a-z]|[a-z]+)").equals(1)) {
            adbno = Piece(adstreet, " ", 1, 1) +"-"+ Piece(adstreet, " ", 3, 3);
            adstreet = Piece(adstreet, " ", 4, 40);
            return adbno+"~"+adstreet+"~"+adflat+"~"+adbuild;
        }

        //f66a Off road
        // ?1"off"1" "1l.e
        // ^(off )([a-z]|[a-z]\w)
        if (RegEx(adstreet, "^(off )([a-z]|[a-z]\\w)").equals(1)) {
            Integer $d = repository.XSTR(Piece(adstreet," ",2,20), 0);
            if ($d.equals(1)) {
                adstreet = Piece(adstreet, " ",2, 20);
            }
        }

        // f67 11 high street
        // ?1n.n1" "2l.e
        //^[0-9]+( )([a-z]{2}|[a-z]{2}\w)
        if (RegEx(adstreet, "^[0-9]+( )([a-z]{2}|[a-z]{2}\\w)").equals(1)) {
            adbno = Piece(adstreet, " ", 1 ,1);
            adstreet = Piece(adstreet, " ", 2, 10);
            // f68
            // adstreet?1"flat "1n.n.l1" "1l.e
            // ^[(flat )[0-9]+( )([a-z]|[a-z]+)
            if (RegEx(adstreet, "^(flat )[0-9]+( )([a-z]|[a-z]+)").equals(1)) {
                if (adflat.isEmpty()) {
                    adflat = Piece(adstreet, " ", 1, 2);
                    adstreet = Piece(adstreet, " ", 3, 20);
                }
            }

            Integer $d = repository.FLAT(adflat);
            if ($d.equals(1)) {
                adflat = adbno; adbno = "";
            }

            return adbno+"~"+adstreet+"~"+adflat+"~"+adbuild;
        }

        // f69 100 s0oth
        // ?1n.n1" "1l.n.l.e
        // ^[0-9]+( )[a-z][0-9]([a-z]|[a-z]+)
        if (RegEx(adstreet, "^[0-9]+( )[a-z][0-9]([a-z]|[a-z]+)").equals(1)) {
            adbno = Piece(adstreet, " ", 1, 1);
            adstreet = Piece(adstreet, " ", 2, 10);
        }

        // f70 ;123-15 dunlace road
        // ?1n.n1"-"1n.n1" "1l.e
        // ^[0-9]+(-)[0-9]+( )([a-z]|[a-z]+)
        if (RegEx(adstreet, "^[0-9]+(-)[0-9]+( )([a-z]|[a-z]+)").equals(1)) {
            adbno = Piece(adstreet, " ", 1, 1);
            adstreet = Piece(adstreet, " ", 2, 20);
            return adbno+"~"+adstreet+"~"+adflat+"~"+adbuild;
        }

        // f71 ;11a high street
        // ?1n.n1l1" "1l.e
        // ^[0-9]+[a-z]( )([a-z]|[a-z]+)
        if (RegEx(adstreet, "^[0-9]+[a-z]( )([a-z]|[a-z]+)").equals(1)) {
            adbno = Piece(adstreet, " ", 1, 1);
            adstreet = Piece(adstreet, " ", 2, 20);
            return adbno+"~"+adstreet+"~"+adflat+"~"+adbuild;
        }

        // f72 ;14 - 16 lower clapton road
        // ?1n.n1" "1"-"1" "1n.n1" "1l.e
        // ^[0-9]+( - )[0-9]+( )([a-z]|[a-z]+)
        if (RegEx(adstreet, "^[0-9]+( - )[0-9]+( )([a-z]|[a-z]+)").equals(1)) {
            adbno = Piece(adbno, " ", 1, 1) +"-"+ Piece(adstreet, " ", 2, 2);
            adstreet = Piece(adstreet, " ", 4, 10);
            return adbno+"~"+adstreet+"~"+adflat+"~"+adbuild;
        }

        // f73 ;109- 111 leytonstone road....
        // ?1n.n1"-"1" "1n.n1" ".l.e
        // ^[0-9]+(- )[0-9]+( )([a-z]|[a-z]+)
        if (RegEx(adstreet, "^[0-9]+(- )[0-9]+( )([a-z]|[a-z]+)").equals(1)) {
            adbno = Piece(adstreet, " ", 1, 1);
            adstreet = Piece(adstreet, " ", 2, 20);
            return adbno+"~"+adstreet+"~"+adflat+"~"+adbuild;
        }

        // f74 ; 109a-111 leytonstone road....
        // ?1n.n1l1"-"1n.n1" "1l.e
        // ^[0-9]+[a-z](-)[0-9]+( )([a-z]|[a-z]+)
        if (RegEx(adstreet, "^[0-9]+[a-z](-)[0-9]+( )([a-z]|[a-z]+)").equals(1)) {
            adbno = Piece(adstreet, " ", 1, 1);
            adstreet = Piece(adstreet, " ", 2, 20);
            return adbno+"~"+adstreet+"~"+adflat+"~"+adbuild;
        }

        // f75 ;110haley road
        // ?1n.n2l.l1" "2l.e
        // ^[0-9]+([a-z]{2}|[a-z]{2}\w+)( )([a-z]{2}|[a-z]{2}\w+)
        //
        // ** TO DO debug loop
        if (RegEx(adstreet, "^[0-9]+([a-z]{2}|[a-z]{2}\\w+)( )([a-z]{2}|[a-z]{2}\\w+)").equals(1)) {
            Integer z = adstreet.length();
            for (Integer i=1; i<=z; i++) {
                if (!Character.isDigit(adstreet.charAt(i-1))) {
                    break;
                }
                adbno = adbno + adstreet.substring(i-1, i);
            }
            adstreet = Piece(adstreet, adbno, 2, 10);
            return adbno+"~"+adstreet+"~"+adflat+"~"+adbuild;
        }

        // f76 ;1a
        // ?1n.n1l
        // ^[0-9]+[a-z]$
        if (RegEx(adstreet, "^[0-9]+[a-z]$").equals(1)) {
            adbno = adstreet;
            adstreet = "";
            return adbno+"~"+adstreet+"~"+adflat+"~"+adbuild;
        }

        // f77 ;99 a high street
        // ?1n.n1" "1l1" ".e
        // ^[0-9]+( )[a-z]( )\w+
        if (RegEx(adstreet, "^[0-9]+( )[a-z]( )\\w+").equals(1)) {
            // f78
            if (Piece(adstreet, " ", 2, 2).equals("y")) {
                adbno = Piece(adstreet, " ", 1, 1);
                adstreet = Piece(adstreet, " ", 2, 20);
            }
            else {
                // f79
                adbno = Piece(adstreet, " ", 1, 1) + Piece(adstreet, " ", 2, 2);
                adstreet = Piece(adstreet, " ", 3, 20);
            }
            return adbno+"~"+adstreet+"~"+adflat+"~"+adbuild;
        }

        // f80 ;9a-11b high street
        // ?1n.n1l1"-"1n.n1l1" ".l.e
        // ** TO DO check that m pattern match is correct?
        // 9a-11b passes m pattern match
        // ^[0-9]+[a-z](-)[0-9]+[a-z]( )([a-z]|[a-z]+)
        // ^[0-9]+[a-z](-)[0-9]+[a-z]+
        if (RegEx(adstreet, "^[0-9]+[a-z](-)[0-9]+[a-z]+").equals(1)) {
            adbno = Piece(adstreet, " ", 1, 1);
            adstreet = Piece(adstreet, " ", 2, 20);
            return adbno+"~"+adstreet+"~"+adflat+"~"+adbuild;
        }

        // f81 ;10-10a blurton road
        // ?1n.n1"-"1n.n1l1" "1l.e
        // ^[0-9]+(-)[0-9]+[a-z]( )([a-z]|[a-z]+)
        if (RegEx(adstreet, "^[0-9]+(-)[0-9]+[a-z]( )([a-z]|[a-z]+)").equals(1)) {
            adbno = Piece(adstreet, " ", 1, 1);
            adstreet = Piece(adstreet, " ", 2, 20);
        }

        // f82 ;99- high street
        // ?1n.n1"-"1" "1l.e
        // ^[0-9]+(- )([a-z]|[a-z]+)
        if (RegEx(adstreet, "^[0-9]+(- )([a-z]|[a-z]+)").equals(1)) {
            adbno = Piece(adbuild, "-", 1, 1);
            adstreet = Piece(adstreet, " ",2, 20);
        }

        // f83 ;westdown road 99
        Integer i = CountPieces(adstreet, " ");
        // ?1n.n
        if (RegEx(Piece(adstreet, " ",i, i),"^[0-9]+$").equals(1)) {
            adbno = Piece(adstreet, " ",i, i);
            adstreet = Piece(adstreet, " ",1, (i-1));
        }

        // f841 ; no example im m code
        // 88-89 <= guess
        // 1n.n1"-"1n.n
        // ^[0-9]+(-)[0-9]+$
        if (adbno.isEmpty() && RegEx(adstreet,"^[0-9]+(-)[0-9]+$").equals(1)) {
            adbno = adstreet;
            adstreet = "";
            if (!adloc.isEmpty()) {
                adstreet = adloc; adloc = "";
            }
        }

        return adbno+"~"+adstreet+"~"+adflat+"~"+adbuild;
	}

	// splitstr(adflat,adbuild,adbno,adstreet,.adflat,.adbuild,.adbno,.adstreet)
	public static String splitstr(String oflat, String obuild, String obno, String ostreet, String adflat, String adbuild, String adbno, String adstreet, Repository repository) throws SQLException
    {
        // ;Splits up building into street and vice versa
        Integer l = CountPieces(obuild, " ");
        Integer i;
        for (i = 1; i <= l; i++) {
        	// ?1n.n
            if (RegEx(Piece(obuild, " ",i, i),"^[0-9]+$").equals(1)) {
                if (repository.hasflat(Piece(obuild, " ", i+1, i+10)).equals(1)) {
                    adbno = adflat;
                    String xstreet = adstreet;
                    adstreet = Piece(obuild, " ", 1, i-1);
                    adflat = Piece(obuild, " ", i, i+10);
                    adbuild = xstreet;
                }
            }
        }
        return adflat +"~"+ adbuild +"~"+ adbno +"~"+ adstreet;
    }

    public static int ConverStrtoNum(String num)
	{
		int xnum;
		try {
			xnum = Integer.parseInt(num);
		}
		catch (NumberFormatException e)
		{
			xnum = 0;
		}
		return xnum;
	}

	// a version of format^UPRNA
	public static String format(Repository repository, String adrec, String oadrec) throws SQLException, IOException {

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

		// test
		// address = address.replace(" to - ", "-");

		address = address.replace(",", " ");
		address = address.replace("',", "");
		address = address.replace("/","-");

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

		// ** TO DO double check that we need this code
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
						//System.out.println(word);
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
			// ?1n.n."-".n
			// ?1l.e
			if (RegEx(Piece(address, d, 1, 1), "^(^[0-9]+$|[0-9]+(-)[0-9]+)").equals(1) && RegEx(Piece(address, d, 2, 2), "^([a-z]|[a-z]+)").equals(1)) {
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
			// ?1n.n
			// ?1l.e
			if (RegEx(Piece(address, d, 2, 2), "^[0-9]+$").equals(1) && RegEx(Piece(address, d, 3, 3), "^([a-z]|[a-z]+)").equals(1)) {
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
						if (RegEx(Piece(adstreet," ",i-1,i-1), "^([0-9]+|[0-9]+[a-z]+)$").equals(1)) {
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
				// flat 43 48church road~e153hz
				if (RegEx(adstreet,"^[a-z]+").equals(1)) {
					for (i = 1; i <= CountPieces(adstreet," "); i++) {
						if (!adbuild.isEmpty()) {break;}
						// ?1n.n.l <= \\d\\w
						if (RegEx(Piece(adstreet, " ", i, i),"^([0-9]+|[0-9]+[a-z]+)$").equals(1)) {
							if (RegEx(Piece(adstreet, " ", i+1, i+1),"\\d\\w").equals(1)) {
								adbuild = Piece(adstreet," ",1,i);
								adstreet = Piece(adstreet, " ", i+1, 20);
								continue;
							}
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

		// f10
		if (addlines.equals(2)) {
			adbuild = Piece(address, d, 1, 1);
			adstreet = Piece(address, d, 2, 2);
			// ?1n.n
			if (RegEx(adstreet,"^[0-9]+$").equals(1) && !adbuild.isEmpty()) {
				adstreet = adstreet + " " + adbuild;
				adbuild = "";
			}
		}

		// f11
		if (addlines.equals(3)) {
			adbuild = Piece(address, d, 1, 1);
			adstreet = Piece(address, d, 2, 2);
			adloc = Piece(address, d, 3, 3);
			System.out.println("f11");
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

		String ret = f17(adeploc, adstreet, adbuild, adepth, repository);
		adeploc = Piece(ret,"~",1,1); adstreet = Piece(ret,"~",2,2); adbuild = Piece(ret,"~",3,3); adepth=Piece(ret,"~",5,5);

		/*
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
		 */

		// Location is street, street is building
		ret = f23(adloc, adstreet, adbuild, adflat, repository);
		adloc = Piece(ret, "~", 1, 1); adstreet = Piece(ret, "~", 2, 2); adbuild = Piece(ret, "~", 3, 3); adflat = Piece(ret, "~", 4, 4);

		/*
		// Location is street, street is building
		// f23
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
					if (RegEx(adstreet, "^[0-9]+$").equals(1) || RegEx(adstreet, "^[0-9]+(-)[0-9]+$").equals(1) || RegEx(adstreet, "^[0-9]+([a-z]|[a-z]+)$").equals(1)) {
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
						}
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
					adbuild = adbuild +" "+adstreet;
					adstreet = adloc;
					adloc = "";
				}
			}
			break;
		}
		 */

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
                        }
						adstreet = Piece(adstreet, " ", 3, 20);
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
                break;
            }
        }

        if (adflat.isEmpty()) {
        	String r = flatbld(adflat, adbuild, repository);
        	adflat = Piece(r, "~", 1, 1);
        	adbuild = Piece(r, "~", 2, 2);
        }

        // do numstr(.adbno,.adstreet,.adflat,.adbuild)
        String r = numstr(adbno, adstreet, adflat, adbuild, adloc, repository);
        adbno = Piece(r, "~", 1, 1); adstreet = Piece(r, "~", 2, 2); adflat = Piece(r, "~", 3, 3);
        adbuild = Piece(r, "~", 4, 4);

        // f84 ;Left shift locality to street, street to building, building to flat?
        // ?1n.n1" "1l.e
        // ^[0-9]+( )([a-z]|[a-z]+)
        if (RegEx(adloc, "^[0-9]+( )([a-z]|[a-z]+)").equals(1)) {
            if (adbuild.isEmpty() && !adbno.isEmpty()) {
                adflat = adflat +" "+ adbno;
                adbuild = adstreet;
                adbno = Piece(adloc, " ", 1, 1);
                adstreet = Piece(adloc, " ", 2, 10);
                adloc = "";
            }
        }

        // f85 ;Is number in the flat field?
        if (isno(adflat).equals(1)) {
            if (adbuild.isEmpty()) {
                if (adbno.isEmpty()) {
                    adbno = adflat;
                    adflat = "";
                }
            }
        }

        // f86 ;Building is street,street is null or not
        // ;111 abbotts park road,  ,
        // ;111 abotts park road, leyton,,
        // ;111 abbotts park road , leyton, leyton

        for (;;) {
            if (isroad(adbuild, repository).equals(1)) {
                // f87
                if (adbno.isEmpty()) {
                    if (adstreet.isEmpty()) {
                        if (isflat(adbuild, repository).equals(1)) {
                            if (RegEx(adbuild, "^[0-9]$").equals(1)) {
                                String xflat = adflat;
                                adflat = Piece(adbuild, " ", 1, 2);
                                adbno = xflat;
                                adbuild = Piece(adbuild, " ", 3, 20);
                                break;
                            }
                        }
                        // f89
                        // ?1l.l.e
                        // ^[a-z]+\w$
                        if (RegEx(adbuild, "^[a-z]+\\w$").equals(1)) {
                            adbno = adflat;
                            adstreet = adbuild;
                            adflat = ""; adbuild = "";
                            break;
                        }
                        // f90
                        // ?1n.n.l1" "1l.e
                        if (RegEx(adbuild, "^[0-9][a-z]( )[a-z]\\w").equals(1)) {
                            adbno = Piece(adbuild, " ", 1, 1);
                            adstreet = Piece(adbuild, " ", 2, 10);
                            adbuild = "";
                            break;
                        }
                    }

                    // f91
                    if (adloc.isEmpty()) {
                        if (isroad(adstreet, repository).equals(0)) {
                            adloc = adstreet;
                            adstreet = adbuild;
                            adbno = adflat;
                            adflat = ""; adbuild = "";
                        }
                    }
                    break;
                }
            }
            break;
        }

        // f92
        if (!adflat.isEmpty() && !adbuild.isEmpty() && adbno.isEmpty() && adstreet.isEmpty()) {
            for (;;) {
                if (adbno.isEmpty() && adstreet.isEmpty()) {
                    // f94
                    if (adflat.contains("flat")) {
                        adstreet = adbuild;
                        adbuild = "";
                        // quit
                        f95:break;
                    }
                    adbno = adflat;
                    adstreet = adbuild;
                    adflat = ""; adbuild = "";
                }
                f95:; // simulate m indentation
                if (adbno.isEmpty() && adloc.isEmpty()) {
                    // f96
                    if (repository.hasflat(adflat+" "+adbuild).equals(0)) {
                        adloc = adstreet;
                        adbno = adflat;
                        adstreet = adbuild;
                        adflat = "";
                        adbuild = "";
                        break;
                    }
                }

                r = splitstr(adflat, adbuild, adbno, adstreet, adflat, adbuild, adbno, adstreet, repository);
                adflat = Piece(r, "~", 1, 1); adbuild = Piece(r, "~", 2, 2); adbno = Piece(r, "~", 3, 3);
                adstreet = Piece(r, "~", 4, 4);

                if (isroad(adstreet, repository).equals(1)) {
                    if (adbno.isEmpty()) {
                        if (adstreet.equals(adloc)) {
                            adstreet = adbuild;
                            adbuild = "";
                            adbno = adflat;
                            break;
                        }
                    }
                    if (!adbno.isEmpty()) {
                        String xbuild = adbuild;
                        String xflat = adflat;
                        adbuild = adstreet;
                        adflat = adbno;
                        adbno = xflat;
                        adstreet = xbuild;
                    }
                }
                break;
            }
        }

        // f100 ;Building is number,make sure street doesn't have the number !
        // ;Number contains flat so assign number to flat
        // ?1n.n.l1" "1n.n.l
        // ^[0-9]+[a-z]( )([0-9]|[0-9]+\w)
        if (RegEx(adbno, "^[0-9]+[a-z]( )([0-9]|[0-9]+\\w)").equals(1)) {
            adflat = Piece(adbno, " ", 1, 1);
            adbno = Piece(adbno, " ", 2, 2);
        }

        // f101 Strip space from number to assign suffix
        // ?1n.n1" "1l
        // ^[0-9]+( )[a-z]$
        if (RegEx(adbno, "^[0-9]+( )[a-z]$").equals(1)) {
            adbno = adbno.replace(" ", "");
        }

        // f102 ;Street is a number, locality is the street
        if (isno(adstreet).equals(1)) {
            if (!adbno.isEmpty()) {
                adbno = adstreet;
                adstreet = adloc;
                adloc = "";
            }
        }

        // f103 ;Locality is street, street is building
        if (isroad(adloc, repository).equals(1)) {
            if (adflat.isEmpty() && adbuild.isEmpty()) {
                adflat = adbno; adbno = "";
                adbuild = adstreet;
                adstreet = adloc; adloc = "";
            }
        }

        // f104 ;Confusing flat number now split out
        if (isflat(adbuild, repository).equals(1)) {
            // f105
            for (;;) {
                if (adflat.equals(adbno)) {
                    adflat = Piece(adbuild, " ", 1, 2);
                    adbuild = Piece(adbuild, " ", 3, 10);
                }
                // f106
                else {
                    if (!adflat.isEmpty()) {
                        // f107
                        // ; room f unite stratford
                        // ?1l.l1" "1l1" "1l.e
                        // ^[a-z]+( )[a-z]( )([a-z]|[a-z]+)
                        if (RegEx(adbuild, "^[a-z]+( )[a-z]( )([a-z]|[a-z]+)").equals(1)) {
                            adflat = adflat + " " + Piece(adbuild, " ", 1, 2);
                            adbuild = Piece(adbuild, " ", 3, 20);
                            break;
                        }
                        // f108
                        // room h
                        // ?1l.l1" "1l
                        // ^[a-z]( )[a-z]$
                        if (RegEx(adbuild, "^[a-z]( )[a-z]$").equals(1)) {
                            adflat = adflat +" "+ Piece(adbuild, " ", 1, 2);
                            adbuild = Piece(adbuild, " ", 3, 20);
                        }
                        else {
                            // f108a
                            // 1l.l1" "1n.n
                            // ^[a-z]+( )([0-9]+)$
                            if (RegEx(adbuild, "^[a-z]+( )([0-9]+)$").equals(1)) {
                                String xflat = adbuild; adbuild = adflat; adflat = xflat;
                            }
                        }
                    }
                }
                break;
            }
        }

        // f109 ;Street has flat name and flat has street
        if (isflat(adstreet, repository).equals(1)) {
            if (RegEx(adflat, "^[0-9]+$").equals(1)) {
                if (!adbuild.isEmpty()) {
                    String flatbuild = "";
                    if (!adbno.isEmpty()) {
                        flatbuild = adbno +" "+ adstreet;
                    }
                    else {
                        flatbuild = adstreet;
                    }
                    adbno = adflat;
                    adstreet = adbuild;
                    adflat = Piece(flatbuild, " ", 1, 2);
                    adbuild = Piece(flatbuild, " ", 3, 20);
                    if (RegEx(adbuild, "^[a-z]$").equals(1)) {
                        adflat = adflat +" "+ adbuild; adbuild = "";
                    }
                }
            }
        }

        // f110 ;Duplicate flat building number and street,remove flat and building
        if (!adflat.isEmpty() && !adbuild.isEmpty() && !adbno.isEmpty() && !adstreet.isEmpty()) {
            String xadbno = extractNumber(adbno) +" "+ adstreet;
            Integer l = (extractNumber(adflat)+" "+adbuild).length();
            if (xadbno.length()>=l) {
				if (xadbno.substring(0, l).equals(extractNumber(adflat) + " " + adbuild)) {
					// i adflat?1n.nl,adbno?1n.n d
					if (RegEx(adflat, "^([0-9]+|[0-9]+[a-z]+)$").equals(1) && RegEx(adbno, "^[0-9]+$").equals(1)) {
						adbno = adflat;
					}
					adflat = "";
					adbuild = "";
				}
			}
        }

        // f1101 ;first floor 96a second avenue
        // ;street contains flat term before the number
        if (adbno.isEmpty()) {
            length = CountPieces(adstreet, " ");
            for (i = 2; i <= length; i++) {
                String word = Piece(adstreet, " ", i, i);
                // f111
                // 1n.n.l
                if (RegEx(word, "^[0-9][a-z]+$").equals(1)) {
                    if (adflat.isEmpty() && adbuild.isEmpty()) {
                        adflat = Piece(adstreet, " ", 1, i - 1);
                        // f112
                    } else {
                        if (!adflat.isEmpty()) {
                            // f113
                            if (adbuild.isEmpty()) {
                                adbuild = Piece(adstreet, " ", 1, i - 1);
                            } else {
                                // f114
                                adbuild = adbuild +" "+ Piece(adstreet, " ",1, i-1);
                            }
                        }
                    }
                    adbno = word;
                    adstreet = Piece(adstreet, " ", i+1, 20);
                }
            }
        }

        // f115 ;street contains flat number near the end
        if (adstreet.contains(" flat ")) {
            adflat = "flat " + Piece(adstreet,"flat ", 2, 10);
            adstreet = Piece(adstreet, " flat", 1, 1);
        }

        // f116 ;Bulding is number suffix
        // ; a~12 high street
        // if adbuild?1l,adflat="",adbno?1n.n do
        if (RegEx(adbuild, "^[a-z]$").equals(1) && RegEx(adbno, "^[0-9]$").equals(1)) {
            adbno = adbno + adbuild;
            adbuild = "";
        }

        // f117 ;Street number mixed with flat and building
        // ;20 284-288 haggerston studios~ kingsland road
        // ?1n.n1" "1n.n."-".n1" "1l.e
        // ^[0-9]+( )[0-9]+(-)[0-9]+( )([a-z]+)
        if (RegEx(adbuild, "^[0-9]+( )[0-9]+(-)[0-9]+( )([a-z]+)").equals(1)) {
            if (adflat.isEmpty() && adbno.isEmpty()) {
                adflat = Piece(adbuild, " ", 1, 1);
                adbno = Piece(adbuild, " ", 2, 2);
                adbuild = Piece(adbuild, " ",3, 20);
            }
        }

        // f118 ;duplicate flat number in building number without street
        // ;46, 46 ballance road
        // ?1n.n1" "1n.n
        if (RegEx(adbuild, "^[0-9]+( )[0-9]+$").equals(1)) {
            if (adbno.isEmpty() && adflat.isEmpty()) {
                adbno = Piece(adbuild, " ", 2, 2);
                adflat = Piece(adbuild, " ", 1, 1);
                adbuild = "";
            }
        }

        // f119 ;110 , 110 carlton road
		int xadflat = ConverStrtoNum(adflat);

		if (adflat.equals(adbno) && adbuild.isEmpty() && xadflat > 20) { adflat = "";}

		// f120 ;street number is in location!
		// ; bendish road , 11
		if (RegEx(adloc, "^[0-9]+$").equals(1) && adbno.isEmpty()) {
			adbno = adloc;
			adloc = "";
		}

		// f121 ;Error in flat number
		// ;flat go1
		// ?1l.l1"o"1n.n
		// [a-z]+(o)[0-9]+$
		if (RegEx(Piece(adflat, " ", 2, 2),"[a-z]+(o)[0-9]+$").equals(1)) {
			adflat = setSingle$Piece(adflat, " ", Piece(adflat," ",2, 2).replace("o","0"), 2);
		}

		// f122 ;Now has flat as number and number still in street
		// ;,,flat 1, 22 plashet road
		if (!adbno.isEmpty() && isno(Piece(adstreet, " ",2, 2)).equals(1)) {
			if (adflat.isEmpty() && adbuild.isEmpty()) {
				adflat = adbno;
				adbno = Piece(adstreet, " ", 1, 1);
				adstreet = Piece(adstreet, " ", 2, 20);
			}
		}

		// f123 ;area in street
		if (adloc.isEmpty() && CountPieces(adstreet, " ")>1) {
			if (repository.XBLD(adstreet, 0).equals(0) && repository.XSTR(adstreet,0).equals(0)) {
				Integer z = CountPieces(adstreet, " ");
				if (repository.TOWN(Piece(adstreet, " ", z, z)).equals(1)) {
					adloc = Piece(adstreet, " ", z, z);
					adstreet = Piece(adstreet, " ", 1, z-1);
				}
			}
		}

		// f124 ;building is the number
		if (isno(adbuild).equals(1) && !adstreet.isEmpty() && adbno.isEmpty()) {
			adbno = adbuild;
			adbuild = "";
		}

		// f125 ;suffixes split across fields
		// ?1l1" "1l.e
		// ^[a-z]( )([a-z]|[a-z]+)
		if (!adflat.isEmpty() && RegEx(adbuild, "^[a-z]( )([a-z]|[a-z]+)").equals(1)) {
			adflat = adflat + adbuild.substring(0, 1);
			adbuild = adbuild.substring(1, adbuild.length());
		}

		// f126
		if (!adbno.isEmpty() && RegEx(adstreet, "^[a-z]( )([a-z]|[a-z]+)").equals(1)) {
			if (!adstreet.substring(0, 1).equals("y")) {
				adbno = adbno + adstreet.substring(0, 1);
				adstreet = Piece(adstreet, " ", 2, 20);
			}
		}

		// f127 ;Two streets
		if (isroad(adloc, repository).equals(1) && isroad(adstreet, repository).equals(1)) {
			if (adflat.isEmpty() && adbuild.isEmpty()) {
				adflat = adbno;
				adbuild = adstreet;
				adbno = "";
				adstreet = adloc;
				adloc = "";
			}
		}

		// f128 ;009
		// ;strip leading zeros
		if (RegEx(adflat, "^[0-9]+$").equals(1)) {
			adflat = adflat.replaceFirst("^0*", "");
		}

		// f129 ;Building ends in number
		// ?1l.l1" "1l.l.e
		// ^[a-z]+( )([a-z]|[a-z]+)
		if (adbno.isEmpty() && adflat.isEmpty() && RegEx(adstreet,"^[a-z]+( )([a-z]|[a-z]+)").equals(1)) {
			Integer z = CountPieces(adbuild, " ");
			if (RegEx(Piece(adbuild, " ", z, z), "^[0-9]+$").equals(1)) {
				adbno = Piece(adbuild, " ", z, z);
				adbuild = Piece(adbuild, " ", 1, z-1);
			}
		}

		// ;Correct spelling
		// f130
		// i '$d(address("obuild")) s address("obuild")=adbuild <= ** TO DO need to add to hash
		// s address("ostr")=adstreet <= add to hash

		adbuild = correct(adbuild, repository);
		adstreet = correct(adstreet, repository);

		// set adflat=$$flat^UPRNU($$co($$correct^UPRNU(adflat)))
		adflat = flat(co(correct(adflat, repository)), repository);

		// f131
		if (!adbno.isEmpty()) {
			adbno = flat(co(correct(adbno, repository)), repository);
		}

		// f132 ;Duplicate building
		if (adbuild.equals(adstreet)) {
			if (adbno.isEmpty() && !adflat.isEmpty()) {
				adbno = adflat;
				adbuild = "";
				adflat = "";
			}
		}

		// f133 ;Street still has number
		// 1n.n1l1" "1l.e
		if (RegEx(adstreet, "^[0-9]+[a-z]( )([a-z]|[a-z]+)").equals(1) && adbno.isEmpty() && !adflat.isEmpty()) {
			adbno = Piece(adstreet, " ", 1, 1);
			adstreet = Piece(adstreet, " ", 2, 10);
		}

		// f134 ;Street contains building
		if (!adbuild.isEmpty() && adflat.isEmpty()) {
			if (isroad(adstreet, repository).equals(1)) {
				Integer z = CountPieces(adstreet, " ")-2;
				for (i = 1; i <= z; i++) {
					// f135
					if (repository.BUILDING(Piece(adstreet," ",i,i)).equals(1) || repository.COURT(Piece(adstreet," ",i,i)).equals(1)) {
						adbuild = Piece(adstreet, " ",1, i);
						adstreet = Piece(adstreet, " ", i+1, z);
						adflat = adbno;
						adbno = "";
					}
				}
			}
		}

		// f136 ;dependent locality has number
		// i adepth?1n.n1l!(adeploc?1n.n),adbno="" d
		if (RegEx(adepth, "^[0-9]+[a-z]$").equals(1) || RegEx(adeploc, "^[0-9]+$").equals(1)) {
			adbno = adepth;
			adepth = "";
		}

		// f137 ;House and street in same line
		if (adflat.isEmpty() && adbuild.isEmpty() && !adbno.isEmpty() && CountPieces(adstreet, " ")>2) {
			int lenstr = CountPieces(adstreet, " ");
			if (RegEx(Piece(adstreet, " ", lenstr, lenstr),"^[0-9]+").equals(1)) {
				Integer strfound = 0;
				for (i = 1; i <= lenstr-1; i++) {
					if (strfound.equals(1)) break;
					// f138
					if (repository.XSTR(Piece(adstreet, " ", i, lenstr-1), 0).equals(1)) {
						strfound = 1;
						adflat = adbno;
						adbno = Piece(adstreet, " ",lenstr, lenstr);
						adbuild = Piece(adstreet, " ", 1, i-1);
						adstreet = Piece(adstreet, " ", i, lenstr-1);
					}
				}
			}

			// f139
			// tests for 0 rather than 1
			// I $D(^UPRNX("X.STR",adstreet)) q
			if (repository.XSTR(adstreet, 0).equals(0)) {
				for (i = CountPieces(adstreet, " ")-2; i==2; i--) {
					if (repository.XSTR(Piece(adstreet," ",i, CountPieces(adstreet, " ")), 0).equals(1)) {
						adflat = adbno;
						adbuild = Piece(adstreet, " ", 1, i-1);
						adbno = "";
						adstreet = Piece(adstreet, " ", i, CountPieces(adstreet, " "));
					}
				}
			}
		}

		// f140 ;Shifts building to stree if its in street dictionary
		if (adbno.isEmpty() && !adbuild.isEmpty() && !adflat.isEmpty()) {
			for (;;) {
				if (repository.XSTR(adbuild, 0).equals(1)) {
					if (repository.XSTR(adstreet, 0).equals(0)) {
						if (adloc.contains(" ")) { break; }
						if (!adeploc.isEmpty()) {
							String xadloc = "";
							if (!adloc.isEmpty()) xadloc = " ";
							adloc = adeploc + xadloc + adloc;
							adeploc = adstreet;
						}
						else {
							adloc = adstreet;
						}
						adstreet = adbuild;
						adbno = adflat;
						adflat = "";
						adbuild = "";
					}
				}
				break;
			}
		}

		// f141 ;town in street
		String adtown = "";
		if (!adloc.isEmpty() && adbno.isEmpty()) {
			if (repository.TOWN(adloc).equals(1)) {
				if (!adstreet.isEmpty()) {
					if (repository.TOWN(adstreet).equals(1)) {
						adtown = adloc;
						adloc = adstreet;
						adstreet = adbuild;
						adbno = adflat;
						adflat = ""; adbuild = "";
					}
				}
			}
		}

		// f142 ;Looks for more verticals
		if (repository.VERTICALS(adflat +" "+ adbuild).equals(1)) {
			adflat = adflat +" "+adbuild;
			adbuild = "";
		}

		// F142a
		if (adflat.isEmpty()) {
			Integer numpos = numpos(adbuild);
			if (numpos>0) {
				if (repository.VERTICALS(Piece(adbuild, " ", 1, numpos-1)).equals(1)) {
					adflat = Piece(adbuild, " ", 1, numpos);
					adbuild = Piece(adbuild, " ", numpos+1, 20);
				}
			}
		}

		// f143
		if (adflat.isEmpty()) {
			String fbuild = adbuild;
			// f144
			if (isflat(Piece(adbuild, " ", 1, 1), repository).equals(1)) { fbuild = Piece(adbuild, " ",2, 20); };
			for (i = CountPieces(fbuild, " "); i==2; i--) {
				if (repository.VERTICALS(Piece(fbuild, " ",1, i)).equals(1)) {
					adflat = Piece(fbuild, " ", 1, i);
					adbuild = Piece(fbuild, " ", i+1, 20);
					break;
				}
			}
		}

		// f145 ;Flat not yet found
		if (adflat.isEmpty() && !adbuild.isEmpty() && !adstreet.isEmpty()) {
			for (i = 1; i <= CountPieces(adbuild, " "); i++) {
				// ?1n.n.l
				if (RegEx(Piece(adbuild, " ", i , i), "^([0-9]+|[0-9]+[a-z]+)$").equals(1)) {
					adflat = Piece(adbuild, " ", 1, i);
					adbuild = Piece(adbuild, " ", i+1, 20);
					break;
				}
				/* this is code that is not executed - take a look at the mumps code?
				if (!adflat.isEmpty()) { continue; }
				// i adbuild?1"studio"1" "1l
				if (RegEx(adbuild, "^(studio)( )[a-z]$").equals(1)) {
					continue;
				}
				 */
			}
		}

		// f147 ;Look again for verticals
		// ;Still looking
		// i adbuild?1p1" ".e <= punctuation
		//if (RegEx(adbuild, "^[!\"#$%&'()*+,-.\\/:;<=>?@[\\]^_`{|}~]( )[a-z]+").equals(1)) {
		// \\p{Punct}

		if (RegEx(adbuild, "(~!#*+,-.:;<=>?@`|\\{\\}\\^`)( )[a-z]+").equals(1)) {
			if (repository.VERTICALS(Piece(adbuild, " ", 2, 20)).equals(1)) {
				adflat = adflat +" "+ Piece(adbuild, " ", 2, 20);
				adbuild = "";
			}
		}

		// f148
		if (repository.VERTICALS(adbuild).equals(1)) {
			if (adflat.isEmpty()) {
				adflat = adbuild;
			}  else { adflat = adflat +" "+adbuild; }
			adbuild = "";
		}

		// f149
		// ;Probably got flat and number wrong
		// i adbuild="flat",adflat?1n.n1l,adbno?1n.n
		if (adbuild.equals("flat") && RegEx(adflat, "^[0-9]+[a-z]$").equals(1) && RegEx(adbno,"^[0-9]+$").equals(1)) {
			String temp = adflat;
			adflat = adbno;
			adbno = temp;
			adbuild = "";
		}

		// f150 ;Building has range number in it
		Integer z = CountPieces(adbuild, " ");
		if (adbno.isEmpty() && RegEx(Piece(adbuild," ", z, z), "^[0-9]+(-)[0-9]+").equals(1)) {
			adbno = Piece(adbuild, " ", z, z);
			adbuild = Piece(adbuild, " ", 1, z-1);
			if (repository.VERTICALS(adflat +" "+ adbuild).equals(1)) {
				adflat = adflat +" "+adbuild;
				adbuild = "";
			}
		}

		//f151 ; Street is building
		if (!adflat.isEmpty() && adbuild.isEmpty() && adbno.isEmpty() && repository.XSTR(adbuild+" "+adstreet, 0).equals(0)) {
			if (repository.XBLD(adstreet, 0).equals(1)) {
				adbuild = adstreet; adstreet = "";
			}
		}

		//f152 ;Flat contains street number
		// 1n.n1" "1n.n
		if (RegEx(adflat, "^[0-9]+( )[0-9]+$").equals(1) && adbno.isEmpty() && repository.XSTR(adbuild+" "+adstreet,0).equals(1)) {
			adbno = Piece(adflat, " ", 2, 2);
			adflat = Piece(adflat, " ", 1, 1);
			adstreet = adbuild +" "+adstreet;
			adbuild = "";
		}

		// f153 ; UPRNA1 - ;Additional preformatting routine
		// care home changes
		// Dependent location is street
		if (!adeploc.isEmpty() && adbno.isEmpty() && adflat.isEmpty()) {
			// ?1n.n.e1" "1l.e
			// ^[0-9]+\w+( )[a-z]\w+
			if (RegEx(adeploc, "^[0-9]+\\w+( )[a-z]\\w+").equals(1)) {
				if (repository.XSTR(Piece(adeploc," ", 2, 20), 0).equals(1)) {
					adbno = Piece(adeploc, " ", 1, 1);
					adflat = adbuild; adbuild = adstreet; adstreet = Piece(adeploc, " ", 2, 20);
					adeploc = "";
				}
			}
		}
		// ;is there a name and number or range in the street
		if (!adbuild.isEmpty() && adbuild.equals(adstreet) && repository.XSTR(adbuild, 0).equals(1)) {
			z = CountPieces(adflat, " ");
			// ?1n.n.l
			if (RegEx(Piece(adflat, " ", z, z),"^([0-9]+|[0-9]+[a-z]+)$").equals(1)) {
				adbno = Piece(adflat, " ",z, z);
				adbuild = Piece(adflat, " ", 1, z-1);
				adflat = "";
			}
		}
		// i adbno="",adbuild="" d ????
		z = CountPieces(adstreet, " ");
		for (i = z-1; i==2; i--) {
			String tstr = Piece(adstreet, " ",i, z);
			if (repository.XSTR(tstr, 0).equals(1)) {
				String tstno = Piece(adstreet, " ", i-1, i-1);
				// ?1n.n.l
				// ?1n.n1"-"1n.n
				if (RegEx(tstno, "^([0-9]+|[0-9]+[a-z]+)$").equals(1) || RegEx(tstno, "^[0-9]+(-)[0-9]+$").equals(1)) {
					adbno = Piece(adstreet, " ", i-1, i-1);
					if (i== 2) {
						adstreet = Piece(adstreet, " ", i, z);
					}
					else {
						adbuild = Piece(adstreet, " ",1, i-2);
						adstreet = Piece(adstreet, " ", i, z);
					}
				}
			}
		}
		// I adstreet'="",'$D(^UPRNX("X.STR",adstreet)),adbno="" d ?????
		z = CountPieces(adbuild, " ");
		for (i = z-1; i==2; i--) {
			String tstr = Piece(adbuild, " ",i, z);
			if (repository.XSTR(tstr, 0).equals(1)) {
				String tstno = Piece(adbuild, " ", i-1, i-1);
				// 1n.n.l
				// ?1n.n1"-"1n.n
				if (RegEx(tstno, "[0-9]+[a-z]$").equals(1) || RegEx(tstno, "^[0-9]+(-)[0-9]+$").equals(1)) {
					adbno = Piece(adbuild, " ", i-1, i-1);
					int xadbno = ConverStrtoNum(adflat);
					if (xadbno > 2) {
						adstreet = Piece(adbuild, " ", i, z);
						adbuild = Piece(adstreet, " ", 1, i-2);
					}
				}
			}
		}

		System.out.println("adrec >> " + adrec);
		System.out.println("adflat 'flat' >> "+ adflat);
		System.out.println("adbuild 'building' >> "+ adbuild);
		System.out.println("adbno 'number' >> "+ adbno);
		System.out.println("adepth 'depth' >> "+ adepth);
		System.out.println("adeploc 'deploc' >> "+ adeploc);
		System.out.println("adstreet 'street' >> "+ adstreet);
		System.out.println("adloc 'locality' >> "+ adloc);
		System.out.println("post 'post' >> "+ post);
		System.out.println("adtown >> "+ adtown);

		String F2 = "d:\\temp\\java_address.txt";
		FileWriter fw = new FileWriter(F2,true); //the true will append the new data
		fw.write(oadrec +"\t"+ adbuild +"\t"+ adeploc +"\t"+ adepth + "\t"+ adflat + "\t"+ adloc + "\t"+ adbno +"\t"+ post +"\t"+ adstreet + "\t"+ adtown +"\n");
		fw.close();

		// **** FINISHED ****

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