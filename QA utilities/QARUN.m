QARUN ; ; 7/8/21 12:44pm
 ;
 
 S REG2="/tmp/TEMP/reg2.txt"
 S CEGADR="/tmp/TEMP/ceg-adr.txt"
 
 I $$10^ZOS(REG2)>1 W !,"reg extract does not exist" quit
 I $$10^ZOS(CEGADR)>1 W !,"address extract does not exist" quit
 
 S EPOCH=^ICONFIG("EPOCH")
 S ALGVERSION=^ICONFIG("ALG-VERSION")
 I EPOCH="" W !,"system missing epoch version" quit
 I ALGVERSION="" W !,"system misisng algorithm version" quit
 
 W !,"THIS SYSTEM IS RUNNING THIS VERSION: "
 W !,"EPOCH: ",EPOCH
 W !,"ALG VERSION: ",ALGVERSION
 
YN W !,"Continue (Y/N):"
 R YN#1
 S YN=$$UC^LIB(YN)
 I "\Y\N\"'[("\"_YN_"\") G YN
 I $$UC^LIB(YN)="N" W !,"EXITING" QUIT
 
 
 ;S Q="select pm.id,pm.patient_address_id,pm.uprn,pm.epoch,pm.algorithm_version,pm.match_rule,pm.qualifier,pm.uprn_property_classification,pm.abp_address_postcode from internal_nel_gp_pid.patient_address_match pm"
 ;W !,Q
 ;S KEY=^ICONFIG("CHOMES","KEY"),FILE="/tmp/pam.txt"
 ; 2AA7F19EAD0B04A3FD5E
 ;D STT^CHOMES("2AA7F19EAD0B04A3FD5E",KEY,Q,FILE)
 
 ;S Q="select id,address_line_1,address_line_2,address_line_3,address_line_4,city,postcode from internal_nel_gp_pid.patient_address"
 ;W !,Q
 
 ;S FILE="/tmp/nel_addresses.txt"
 
 ;D STT^CHOMES("2AA7F19EAD0B04A3FD5E",KEY,Q,FILE)
 
 ;
 
 ;S Q="SELECT p.id,p.current_address_id FROM internal_nel_gp_pid.patient p join internal_nel_gp_pid.episode_of_care e on e.patient_id = p.id join internal_nel_gp_pid.concept c on c.dbid = e.registration_type_concept_id join internal_nel_gp_pid.patient_address pa on pa.id=p.current_address_id where c.code = 'R' and p.date_of_death IS NULL and e.date_registered <= now() and (e.date_registered_end > now() or e.date_registered_end IS NULL)"
 
 ;W !!,Q
 
 ;S FILE="/tmp/nel_reg.txt"
 ;D STT^CHOMES("2AA7F19EAD0B04A3FD5E",KEY,Q,FILE)
 
 ; RUN EACH STEP
 ; EXTRACTS FROM DOWNSTREAM CEG ARE DELIMTED BY A ~
 ; EXTRACTS FROM INTERNAL DATABASES ARE DELIMTED BY $C(9)
 
 ;W !,"include full path to file"
 ; /tmp/TEMP/ceg-patient-address-match.txt
PAM W !,"patient address match file (/tmp/pam.txt, . to quit): "
 R pam
 
 I pam="." quit
 
 I $$10^ZOS(pam)>1 W !,"pam file not found" G PAM
 
 U 0 W !,"CALLING REG2^QA"
 D REG2^QA(REG2,"~")
 
 U 0 W !,"CALLING STEP2^QA"
 D STEP2^QA(pam,"~")
 
 I '$D(^OS) U 0 W !,"CALLING STEP3^QA" D STEP3^QA
 
 U 0 W !,"CALLING STEP4^QA"
 D STEP4^QA
 
 U 0 W !,"CALLING STEP5^QA"
 D STEP5^QA(CEGADR,"~")
 
 ;D STEP5A^QA("/tmp/pam.txt","~")
 U 0 W !,"CALLING STEP5A^QA"
 D STEP5A^QA(pam,"~")
 
 U 0 W !,"CALLING STEP5C^QA"
 D STEP5C^QA
 QUIT
 
 F I=1:1:4 D STEP6^QA(I) ; should job
 D STEP7A^QA
 D DISTINCT^QA
 D ^QA5
 
 QUIT
 
ETHNIC ; missing data extracts
 S KEY=^ICONFIG("CHOMES","KEY")
 ; BARTS
 S Q="select nhs_number from internal_nel_secondary_pid.person p where p.organization_id = 2782572 and nhs_number is not null;"
 S FILE="/tmp/barts.csv"
 D STT^CHOMES("2AA7F19EAD0B04A3FD5E",KEY,Q,FILE)
 W !,"PRESS A KEY:" R *Y
 
 ; HOMERTON
 S Q="select nhs_number from internal_nel_secondary_pid.person p where p.organization_id = 11953981 and nhs_number is not null;"
 S FILE="/tmp/homerton.csv"
 D STT^CHOMES("2AA7F19EAD0B04A3FD5E",KEY,Q,FILE)
 QUIT
