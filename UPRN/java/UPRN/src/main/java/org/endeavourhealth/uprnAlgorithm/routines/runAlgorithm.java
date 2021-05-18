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

	public void GetUPRN(String adrec, String qpost, String country, String summary) throws SQLException {

	    adrec = adrec.replaceAll(",","~");

	    System.out.println(adrec);

        Hashtable<String, String> TUPRN = uprnCommon.ADRQUAL(adrec, country);
        if (TUPRN.get("INVALID") != null) {
            System.out.println(TUPRN.get("INVALID"));
            return;
        }

        //uprnCommon.TestCommon();
		// String json = repository.GetUPRN(adrec);
	}

	@Override
	public void close() throws Exception {
		repository.close();
	}

}