package org.endeavourhealth.uprnAlgorithm.common;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class uprnCommon {

	public static void TestCommon()
	{
		System.out.println("test");
	}

	public static Integer validp(String post)
	{
		String regex = "^[a-z]{1,2}[0-9R][0-9a-z][0-9][abd-hjlnp-uw-z]{2}$";
		Pattern pattern = Pattern.compile(regex);

		Matcher matcher = pattern.matcher(post);
		System.out.println(matcher.matches());

		if (!matcher.matches()) {
			return 0;
		}
		return 1;
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

		System.out.println(">>>> "+ post);

		return hashTable;
	}
}