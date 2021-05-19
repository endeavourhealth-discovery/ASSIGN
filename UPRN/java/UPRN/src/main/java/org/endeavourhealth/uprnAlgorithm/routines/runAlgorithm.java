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

	public String GetUPRN(String adrec, String qpost, String country, String summary, String orgpost) throws SQLException {

	    adrec = adrec.replaceAll(",","~");
	    adrec = adrec.toLowerCase();

	    System.out.println(adrec);

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
		uprnCommon.format(repository, adrec);

		return "{}"; // json
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