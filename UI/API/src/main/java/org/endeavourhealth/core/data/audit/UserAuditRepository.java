package org.endeavourhealth.core.data.audit;

import org.endeavourhealth.core.data.audit.models.AuditAction;
import org.endeavourhealth.core.data.audit.models.AuditModule;

import java.util.UUID;

public class UserAuditRepository {
    public UserAuditRepository(AuditModule.EdsUiModule organisation) {

    }

    public void save(UUID currentUserId, UUID organisationUuid, AuditAction action, String title, Object... paramValuePairs) {
        // Do nothing
    }
}
