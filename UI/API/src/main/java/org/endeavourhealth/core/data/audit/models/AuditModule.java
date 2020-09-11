package org.endeavourhealth.core.data.audit.models;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public enum AuditModule implements IAuditModule{
	EdsUi,
	EdsPatientUi,
	EdsPatientExplorer,
	EdsUserManager;

	public static List<IAuditModule> allSubModules() {
		List<IAuditModule> subModules = new ArrayList<>();
		Collections.addAll(subModules, EdsUiModule.values());
		Collections.addAll(subModules, EdsPatientUiModule.values());
		Collections.addAll(subModules, EdsPatientExplorerModule.values());
		Collections.addAll(subModules, EdsUserManagerModule.values());
		return subModules;
	}

	public IAuditModule getParent() { return null; }

	public enum EdsUiModule implements IAuditModule {
		Security,
		Dashboard,
		Admin,
		Organisation,
		Folders,
		EntityMap,
		Library,
		Monitoring,
		Rabbit,
		Stats,
		PatientIdentity,
		User,
		Service,
		Resource,
		Config,
		Audit,
		Ekb,
		ExchangeAudit;

		public IAuditModule getParent() { return AuditModule.EdsUi; }
	}

	public enum EdsPatientUiModule implements IAuditModule {
		Security,
		MedicalRecord;

		public IAuditModule getParent() { return AuditModule.EdsPatientUi; }
	}

	public enum EdsPatientExplorerModule implements IAuditModule {
		RecordViewer,
		CountReport,
		SqlEditor;

		public IAuditModule getParent() { return AuditModule.EdsPatientExplorer; }
	}

	public enum EdsUserManagerModule implements IAuditModule {
		UserManager,
		RoleManager,
		ClientManager;

		public IAuditModule getParent() { return AuditModule.EdsUserManager; }
	}
}
