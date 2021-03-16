package org.endeavourhealth.RALF;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.PreparedStatement;
import java.util.*;

import org.endeavourhealth.RALF.repository.Repository;
import OpenPseudonymiser.Crypto;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.net.ssl.HttpsURLConnection;
import java.io.File;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;

import org.json.*;

public class generate implements AutoCloseable {

    private final Repository repository;

    public generate(final Properties properties) throws Exception {
        this(properties, new Repository(properties));
    }

    public generate(final Properties properties, final Repository repository) {
        this.repository = repository;
    }

    public void GetRalfs(String pathToCsv, String pathToSalt, String outFile) throws Exception {
        BufferedReader csvReader = new BufferedReader(new FileReader(pathToCsv));
        FileWriter csvWriter = new FileWriter(outFile);
        String row = ""; String sId; String sUPRN;
        byte[] x = Files.readAllBytes(Paths.get(pathToSalt));
        Crypto crypto = new Crypto();
        crypto.SetEncryptedSalt(x);
        TreeMap nameValue = new TreeMap();
        String digest = "";
        while ((row = csvReader.readLine()) != null) {
            String[] data = row.split("\t");
            sId=data[0]; sUPRN=data[1];

            if (sUPRN.isEmpty()) continue;

            nameValue.put("UPRN", "" + sUPRN);
            digest = crypto.GetDigest(nameValue);
            csvWriter.append(sId+","+digest+","+sUPRN);
            csvWriter.append("\n");
            System.out.println(sId + " " + digest);
        }
        csvWriter.flush();
        csvWriter.close();
        csvReader.close();
    }

    public static boolean indexInBound(String[] data, int index){
        return data != null && index >= 0 && index < data.length;
    }

    @Override
    public void close() throws Exception {
        repository.close();
    }

}

