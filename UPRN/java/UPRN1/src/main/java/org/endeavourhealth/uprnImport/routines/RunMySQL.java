package org.endeavourhealth.uprnImport.routines;

import org.endeavourhealth.uprnImport.repository.Repository;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class RunMySQL {
	public void Run(Repository repository) throws SQLException  {
		List<List<String>> result = repository.TestMySQL();
		for(List<String> rec : result)
		{
			System.out.println(rec.get(0));
			System.out.println(rec.get(1));
		}
	}
	public void Reside(Repository repository) throws SQLException, IOException {
		repository.InsertClassifications();
	}

	public void IMPCLASS(Repository repository) throws SQLException, IOException {
		repository.IMPCLASS2();
	}

	public void IMPSTR(Repository repository) throws SQLException, IOException {
		repository.IMPSTR2();
	}

    public void IMPUPC(Repository repository) throws SQLException, IOException {
        repository.IMPUPC();
    }

	public void IMPBPL(Repository repository) throws SQLException, IOException {
		repository.IMPBPL2();
	}

	public void IMPDPA(Repository repository) throws SQLException, IOException {
	    repository.IMPDPA2();
    }

    public void  UPRNS(Repository repository) throws SQLException, IOException {
	    repository.UPRNS();
    }
}