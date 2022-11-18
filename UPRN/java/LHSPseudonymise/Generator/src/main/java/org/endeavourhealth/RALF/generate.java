package org.endeavourhealth.RALF;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.Security;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.sql.PreparedStatement;
import java.util.*;

import org.endeavourhealth.RALF.repository.Repository;
import OpenPseudonymiser.Crypto;

import java.io.File;

import org.apache.commons.io.IOUtils;
import org.bouncycastle.cms.*;
import org.bouncycastle.cms.jcajce.JceCMSContentEncryptorBuilder;
import org.bouncycastle.cms.jcajce.JceKeyTransRecipientInfoGenerator;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.operator.OutputEncryptor;

import java.io.FileInputStream;
import java.io.FileOutputStream;

public class generate implements AutoCloseable {

    private final Repository repository;

    public generate(final Properties properties) throws Exception {
        this(properties, new Repository(properties));
    }

    public generate(final Properties properties, final Repository repository) {
        this.repository = repository;
    }

    public void GetRalfs(String pathToCsv, String pathToSalt, String outFile, String base64Salt) throws Exception {

        BufferedReader csvReader = new BufferedReader(new FileReader(pathToCsv));
        FileWriter csvWriter = new FileWriter(outFile);

        if (outFile.contains("ralfspit")) {
            String row = ""; String sId; String sUPRN;
            byte[] x = Files.readAllBytes(Paths.get(pathToSalt));
            Crypto crypto = new Crypto();
            crypto.SetEncryptedSalt(x);
            TreeMap nameValue = new TreeMap();
            String digest = "";
            while ((row = csvReader.readLine()) != null) {
                String[] data = row.split("\t");
                sId = data[0];
                sUPRN = data[1];

                if (sUPRN.isEmpty()) continue;

                nameValue.put("UPRN", "" + sUPRN);
                digest = crypto.GetDigest(nameValue);
                csvWriter.append(sId + "," + digest + "," + sUPRN);
                csvWriter.append("\n");
                System.out.println(sId + " " + digest);
            }
        }

        if (outFile.contains("nhs_number_spit")) {
            String row = ""; String sId; String sNhsNo;

            byte[] saltBytes = Base64.getDecoder().decode(base64Salt);

            Crypto crypto = new Crypto();
            crypto.SetEncryptedSalt(saltBytes);
            TreeMap nameValue = new TreeMap();

            while ((row = csvReader.readLine()) != null) {
                if (row.isEmpty()) continue;
                String[] data = row.split("\t");
                sId = data[0]; sNhsNo = data[1];
                nameValue.put("nhs_number", "" + sNhsNo);
                String pseudoNhsNumber = crypto.GetDigest(nameValue);
                csvWriter.append(sId + "\t" + pseudoNhsNumber);
                csvWriter.append("\n");
                System.out.println(pseudoNhsNumber);
            }
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

    public static String Piece(String str, String del, Integer from, Integer to) {
        Integer i;

        if (!str.contains(del)) {return str;}

        String p[] = str.split("\\\\"+del, -1);
        String z = "";

        from = from - 1;
        to = to - 1;

        Integer zdel = 0;
        if (to > from) {
            zdel = 1;
        }

        for (i = from; i <= to; i++) {
            if (indexInBound(p, i)) {
                z = z + p[i];
                if (zdel.equals(1)) {
                    z = z + del;
                }
            }
        }

        if (zdel.equals((1)) && !z.isEmpty()) {
            // remove delimeter
            z = z.substring(0, z.length() - del.length());
        }

        return z;
    }
}

