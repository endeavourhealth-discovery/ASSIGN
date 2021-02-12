import {Component, OnInit, ViewChild, ElementRef} from '@angular/core';
import {UPRNService} from "../uprn.service";
import {
  GenericTableComponent,
  ItemLinkageService,
  LoggerService,
  MessageBoxDialogComponent,
  UserManagerService
} from "dds-angular8";
import {ngxCsv} from "ngx-csv";
import {DatePipe} from "@angular/common";
import {UserProject} from "dds-angular8/user-manager";
//import {User} from '/src/app/project/models'; ???
import {Router} from "@angular/router";
//import {ReportData} from "../../reporting/models/ReportData";
//import {UPRNData} from "../models/UPRNData";
import {HttpEventType, HttpErrorResponse } from "@angular/common/http";
import { of } from 'rxjs';
import { catchError, map } from 'rxjs/operators';
// npm install @types/file-saver --save-devtabChanged
import {saveAs as importedSaveAs} from "file-saver";
import { MatTabChangeEvent, MatDialog } from '@angular/material';
import {matDialogAnimations} from "@angular/material/dialog";
import {MatYearView} from "@angular/material/datepicker";
import {MatTableDataSource} from "@angular/material/table";

//import {DataProcessingAgreementService} from "../../data-processing-agreement/data-processing-agreement.service";
//import {Dpa} from "../../data-processing-agreement/models/Dpa";
//import {Organisation} from "../../organisation/models/Organisation";
//import {ReportData} from "../models/ReportData";
//import {Dsa} from "../../data-sharing-agreement/models/Dsa";
//import {Project} from "../../project/models/Project";
//import {DataSharingAgreementService} from "../../data-sharing-agreement/data-sharing-agreement.service";
//import {ProjectService} from "../../project/project.service";

@Component({
  selector: 'app-uprn',
  templateUrl: './uprnui.component.html',
  styleUrls: ['./uprnui.component.css']
})

export class UPRNComponent implements OnInit {
  @ViewChild("fileUpload", {static: false}) fileUpload: ElementRef;
  files = [];

  Region: string;
  Config: string;

  qpost: string;

  lf: string = "[lf]";
  tab: string = "[tab]";

  stuff: any;

  adrec: string;
  orgsearch: string;

  jsondata: string;
  jsonlatlong: string;
  chkcomm: boolean;
  chkcarehomes: boolean;
  chkdiscouprn: boolean;

  wName: string; wOrganisation: string; wRegDate: string; epoch: string; areas: string;

  latitude: string; longitude: string; qualifier: string; xcoordinate: string; ycoordinate: string; pointcode: string;
  organisation: string;

  userId: string;
  reportComplete = true;
  UPRNData: any[];

  downloads: string;
  organizations: string;

  UPRN: string; number: string; flat: string; street: string; town: string; postcode: string; classcode: string; classterm: string;
  dogsEnabled: string;
  admin: string;

  uprntp="ABP Unique Property Reference Number";
  buildingtp = "ABP building element of address string ";
  flattp="ABP flat element of address string";
  numbertp="ABP street number element of address string";
  streettp="ABP street element of address string";
  towntp="ABP town element of address string";
  postcodetp="ABP postcode element of address string";
  orgtp="ABP organisation element of address string";
  classcodetp="ABP property classification code";
  classtermtp = "ABP property classification code description";
  lattp="ABP latitude";
  longtp="ABP longitude";
  Xtp="ABP X coordinate";
  Ytp="ABP Y coordinate";
  pointtp="ABP accuracy of the coordinates";
  qualtp="Nature of UPRN match: best match, parent, child or sibling";
  algtp="The rule from the address matching algorithm that made the match";
  matchposttp="Match pattern for the postcode between input and ABP address";
  matchbuildtp="Match pattern for the building between input and ABP address";
  matchnumbertp="Match pattern for the number between input and ABP address";
  matchflattp="Match pattern for the flat between input and ABP address";
  matchstreettp="Match pattern for the street between input and ABP address";
  matchtowntp="Match pattern for the town between input and ABP address";
  matchorgtp="Match pattern for the organisation between input and ABP address";
  getinfotp = "api/getinfo response";
  getuprntp = "api/getuprn response";

  matchpcode: string; matchnumber: string; matchbuilding: string; matchflat: string;

  algorithm: string;

  sessionId: any;
  filetoupload: string;
  HTML: any;
  arrActivity: string [];
  arrOrgs: string[];
  building: string;

  selectedIndex: any;

  options = {
    fieldSeparator: ',',
    quotestrings: '"',
    decimalseparator: '.',
    showLabels: true,
    headers: ['ID,UPRN,add_format,alg,class,match_build,match_flat,match_number,match_postcode,match_street,abp_number,abp_postcode,abp_street,abp_town,qualifier,add_candidate,abp_building,latitude,longitude,point,X,Y,class_term'],
    showTitle: false,
    title: 'UPRN',
    useTextFile: false,
    useBom: false,
  };

  orgcsv = {
    fieldSeparator: ',',
    quotestrings: '"',
    decimalseparator: '.',
    showLabels: true,
    headers: ['id,name,date,value'],
    showTitle: false,
    title: 'orgcsv',
    useTextFile: false,
    useBom: false,
  }

  zeroTo20 = [
    {value: '0', display: ''}, {value: '1', display: 'EC district'}, {value: '2', display: 'WC district'}, {value: '3', display: 'E district'}, {value: '4', display: 'N district'}, {value: '5', display: 'NW district'},
    {value: '6', display: 'SE district'}, {value: '7', display: 'SW district'}, {value: '8', display: 'W district'}, {value: '9', display: 'BR: Bromley'}, {value: '10', display: 'CR: Croydon'},
    {value: '11', display: 'DA: Dartford'}, {value: '12', display: 'EN: Enfield'}, {value: '13', display: 'HA: Harrow'}, {value: '14', display: 'IG: Ilford'}, {value: '15', display: 'KT: Kingston'},
    {value: '16', display: 'RM: Romford'}, {value: '17', display: 'SM: Sutton'}, {value: '18', display: 'TW: Twickenham'}, {value: '19', display: 'UB: Uxbridge'}, {value: '20', display: 'WD: Watford'}
  ];

  disco_config = [];

  public activeProject: UserProject;

  constructor(private UPRNService: UPRNService,
              private userManagerService: UserManagerService,
              private log: LoggerService,
              private itemLinkageService: ItemLinkageService,
              private datePipe: DatePipe,
              private router: Router,
              public dialog: MatDialog,
  ) {
  }

  ngOnInit() {
    this.dogsEnabled = "1";
    this.selectedIndex = 0;
    this.admin = "0";

    this.downloads = "1";

    this.userManagerService.onProjectChange.subscribe(active => {
      this.activeProject = active;
      this.roleChanged();
    });

    console.log("user id? " + this.activeProject.userId + " " + this.activeProject.organisationId);
    this.userId = this.activeProject.userId;

    this.getRegistration(this.userId);

    this.qpost="";

    //this.stuff = "[{\"value\": \"0\", \"display\": \"\"}, {\"value\": \"1\", \"display\": \"HU district\"}]";
    //this.zeroTo20 = JSON.parse(this.stuff);

    this.getConfigs(this.userId);
  }

  ConfigSelection(event) {
    console.log(this.Config);
  }

  RegionSelection(event) {

    // for multi-select (if we need to implement)
    //for (let pet of this.everyHourHourlyTab) {
      //console.log("test: "+pet);
      //console.log(this.everyHourHourlyTab[pet].display)

      console.log(this.Region);

      if (this.Region=="0") {this.qpost=""};
      if (this.Region=="1") {this.qpost="EC"};
      if (this.Region=="2") {this.qpost="WC"};
      if (this.Region=="3") {this.qpost="E"};
      if (this.Region=="4") {this.qpost="N"};
      if (this.Region=="5") {this.qpost="NW"};
      if (this.Region=="6") {this.qpost="SE"};
      if (this.Region=="7") {this.qpost="SW"};
      if (this.Region=="8") {this.qpost="W"};
      if (this.Region=="9") {this.qpost="BR"};
      if (this.Region=="10") {this.qpost="CR"};
      if (this.Region=="11") {this.qpost="DA"};
      if (this.Region=="12") {this.qpost="EN"};
      if (this.Region=="13") {this.qpost="HA"};
      if (this.Region=="14") {this.qpost="IG"};
      if (this.Region=="15") {this.qpost="KT"};
      if (this.Region=="16") {this.qpost="RM"};
      if (this.Region=="17") {this.qpost="SM"};
      if (this.Region=="18") {this.qpost="TW"};
      if (this.Region=="19") {this.qpost="UB"};
      if (this.Region=="20") {this.qpost="WD"};
    //}

    //for (var key in event) {
    //  console.log(event[key]);
    //}

    console.log(this.qpost);
  }

  getSess() {
    this.UPRNService.getSessionId().subscribe(
      result => {
        this.processSession(result);
      },
      error => {
        this.log.error('Unable to get session');
      }
    )
  }

  processSession(sessionData: any[]) {
    console.log(sessionData);
    let jsonObj = JSON.parse(JSON.stringify(sessionData));
    this.sessionId = jsonObj.session;
    console.log(this.sessionId);
  }

  download(p: string) {
    console.log(this.filetoupload);
    this.UPRNService.downloadFile2(this.filetoupload, this.userId).subscribe(data => saveAs(data, this.filetoupload));

  }

  roleChanged() {
    if (this.activeProject.applicationPolicyAttributes.find(x => x.applicationAccessProfileName == 'Super User') != null) {
      this.userId = null;
    } else {
      this.userId = this.activeProject.userId;
    }
  }

  /*
  uploadFile(file) {
    const formData = new FormData();
    formData.append('file', file.data);
    file.inProgress = true;
    this.UPRNService.upload(formData).pipe(
      map(event => {
        switch (event.type) {
          case HttpEventType.UploadProgress:
            file.progress = Math.round(event.loaded * 100 / event.total);
            break;
          case HttpEventType.Response:
            return event;
        }
      }),
      catchError((error: HttpErrorResponse) => {
        file.inProgress = false;
        return of(`${file.data.name} upload failed.`);
      })).subscribe((event: any) => {
      if (typeof (event) === 'object') {
        console.log(event.body);
      }
    });
  }
   */

  /*
  private uploadFiles() {
    this.fileUpload.nativeElement.value = '';
    this.files.forEach(file => {
      this.uploadFile(file);
    });
  }
   */

  /*
  onClickUpload() {
    console.log("Upload stuff");
    const fileUpload = this.fileUpload.nativeElement;
    fileUpload.onchange = () => {
      for (let index = 0; index < fileUpload.files.length; index++) {
        const file = fileUpload.files[index];
        this.files.push({data: file, inProgress: false, progress: 0});
      }
      this.uploadFiles();
    };
    fileUpload.click();
  }
   */

  onClickGoogleMaps() {
    window.open("https://www.google.com/maps/search/?api=1&query=" + this.latitude + "," + this.longitude, "_blank");
  }

  onClickDownloadTable(filetodownload: string) {
    //alert(filetodownload);
    let z = filetodownload.split("/", 4);
    let f = z[3];

    MessageBoxDialogComponent.open(this.dialog, 'Download', f,
      "Cancel", "OK")
      .subscribe(
        (result) => {
          if (!result) {
            this.filetoupload = filetodownload;
            this.onClickDownload();
          }
        });
  }

  onClickDownloadAll()
  {

    let disco = "1";
    if (this.chkdiscouprn == false || (this.chkdiscouprn == undefined)) {
      console.log("disco not checked");
      disco = "0";
    }

    let ch = "1";
    if (this.chkcarehomes == false || (this.chkcarehomes == undefined)) {
      console.log("care homes not checked");
      ch = "0";
    }

    MessageBoxDialogComponent.open(this.dialog, 'Download All', "This will take a minute or so to run (this will not stop you using the uprn-match)",
      "Cancel", "Continue")
      .subscribe(
        (result) => {
          if (!result) {
            this.onClickDownloadOrganisations(disco, ch);
          }
        });
  }

  onClickDownloadOrganisations(disco: string, ch: string) {
    this.UPRNService.downloadOrgCsv(this.userId, disco, this.Config, ch).subscribe(
      result => {
        this.createOrgCsv(result);
      },
      error => {
        this.log.error('Unable to perform download');
      }
    );
  }

  createOrgCsv(csvdata: Blob) {
    let out = "organizations-output";
    new ngxCsv(csvdata, out, this.orgcsv);
  }

  onClickDownload() {
    this.UPRNService.downloadFile2(this.filetoupload, this.userId).subscribe(
      result => {
        this.processIT(result);
      },
      error => {
        this.log.error('Unable to perform download');
      }
    );
  }

  processIT(csvdata: Blob) {
    let file = this.filetoupload.split("/", 4);
    let out = file[3] + "-output";
    new ngxCsv(csvdata, out, this.options);
  }

  onItemLabelLoaded(event) {
    this.sessionId = "1";
  }

  onClicky(event) {
    event.target.value = ''
  }

  postMethod(files: FileList) {
    this.filetoupload = files.item(0).name;
    let ret = this.UPRNService.postFile(files, this.userId);
  }

  findOrganizations() {
    this.UPRNService.getOrganizations(this.orgsearch, this.Config).subscribe(
      data => {
        this.arrOrgs = data as string[];
        let jsonObj = JSON.parse(JSON.stringify(this.arrOrgs[0]));
        console.log(JSON.stringify(this.arrOrgs[0]));
        this.organizations = "1";
      },
      error => {
        this.log.error('Unable to get organizational data');
      }
    )
  }

  onActivityRefresh() {

    //let data = "[{\"DT\":\"?\",\"A\":\"?\"}]";
    //this.arrActivity = JSON.parse(data)

    this.UPRNService.getActivity(this.userId).subscribe(
      data => {
        this.arrActivity = data as string[];
        let jsonObj = JSON.parse(JSON.stringify(this.arrActivity[0]));
        console.log(JSON.stringify(this.arrActivity[0]));
        this.downloads = "1";
        if (jsonObj.A == "?") {
          console.log("no activity logged");
          this.arrActivity.splice(0);
          this.downloads = "";
        }
      },
      error => {
        this.log.error('Unable to get activity');
      }
    )

  }

  tabChanged(tabChangeEvent: MatTabChangeEvent): void {
    // update Welcome registration date
    if (tabChangeEvent.index == 3) {this.getRegistration(this.userId);}

    if (tabChangeEvent.index == 2) {
      let data = "[{\"DT\":\"?\",\"A\":\"?\"}]";
      this.arrActivity = JSON.parse(data);

      this.onActivityRefresh();

      /*
      this.UPRNService.getActivity(this.userId).subscribe(
        data => {
          this.arrActivity = data as string[];
          let jsonObj = JSON.parse(JSON.stringify(this.arrActivity[0]));
          console.log(JSON.stringify(this.arrActivity[0]));
          if (jsonObj.A == "?") {
            console.log("no activity logged");
            this.downloads = "";
          }
        },
        error => {
          this.log.error('Unable to get activity');
        }
      )
       */
    }

  }

  onClickJSON() {
    if (this.jsonlatlong == undefined) {
      this.jsonlatlong = "Click on Google maps";
    }
    // alert(this.jsonlatlong.replace(/[\r\n\x0B\x0C\u0085\u2028\u2029]+/g, " "));

    // MessageBoxDialogComponent.open(,"a","b","ok");

    window.alert('{"Address_format":"good","Postcode_quality":"good","Matched":true,"UPRN":"46079547","Qualifier":"Best  (residential) match","Classification":"RD04","ClassTerm":"Terraced","Algorithm":"1-match","ABPAddress":{"Number":"32","Street":"West Road","Town":"London","Postcode":"E15 3PY"},"Match_pattern":{"Postcode":"equivalent","Number":"equivalent","Building":"equivalent","Flat":"equivalent"}}');
  }

  async getConfigs(userid: string) {

    let j = await this.UPRNService.getSubConfigs(this.activeProject.userId);
    console.log(">>>>> "+j);
    this.disco_config = JSON.parse(j);

    // default to the first item in the json array
    console.log(JSON.parse(j)[0].display);
    this.Config = JSON.parse(j)[0].display;
  }

  async getRegistration(userid: string) {
    let j = await this.UPRNService.getRegistration(this.activeProject.userId);

    console.log("reg json"+ j);

    let jsonObj = JSON.parse(j);

    this.wName = ""; this.wOrganisation=""; this.wRegDate="";

    console.log(jsonObj.name);
    console.log(jsonObj.epoch);
    console.log(jsonObj.areas);
    console.log(">> "+ jsonObj.admin);

    if (jsonObj.name != "?") {
      this.wName = jsonObj.name;
      this.wOrganisation = jsonObj.organization;
      this.wRegDate = jsonObj.regdate;
      this.epoch = jsonObj.epoch;
      this.areas = jsonObj.areas;
      this.admin = jsonObj.admin;
    }

    if (jsonObj.name == "?") {
      // switch to Welcome tab
      this.dogsEnabled = "";
      this.admin = "";
      this.selectedIndex = 4;
    }
  }

  async onClickAgree(wname: string, worg: string) {

    //this.tabs.splice(0, 1);

    if (wname === '' || (worg === '')) {
      MessageBoxDialogComponent.open(this.dialog, 'Welcome', 'Please enter your Name and Organisation', 'Continue');
      return;
    }

    //this.stuff = await this.UPRNService.postRegistration(wname, worg, this.userId);
    //Post JSON rather than a form
    //this.stuff = await this.UPRNService.RegPostJSON(wname, worg, this.userId);

    await this.UPRNService.RegPostJSON(wname, worg, this.userId).then(
      data => {
        if (data == "OK") {
          //alert("Registration filed OK");
          console.log(">>>> "+data);
          this.dogsEnabled = "1";
          this.selectedIndex = 0;
        }
      },
      error => {
        this.log.error('Unable to post registration');
      }
    )

    /*
    if (this.stuff == "OK") {
      //alert("Registration filed OK");
      this.dogsEnabled = "1";
      this.selectedIndex = 0;
    }
     */
  }

  onClickDownGoogleMaps(uprn: string, launch: any) {
    // api/getuprn
    this.longitude=""; this.latitude="";
    this.UPRNService.getUPRNI(uprn).
      subscribe(
        result => {
          this.processCoord(result, launch);
        },
      error => {
        this.log.error('Unable to process uprn');
        this.reportComplete = true;
      }
    )
  }

  processCoord(activityData: any[], launch: any) {
    console.log(JSON.stringify(activityData));
    this.jsonlatlong = JSON.stringify(activityData);

    let jsonObj = JSON.parse(JSON.stringify(activityData));
    let lat = jsonObj.Latitude; let long = jsonObj.Longitude;
    let x = jsonObj.XCoordinate; let y = jsonObj.YCoordinate;

    this.latitude = lat; this.longitude = long;
    this.xcoordinate = x; this.ycoordinate= y;
    this.pointcode = jsonObj.Pointcode;

    if (launch==1) {
      window.open("https://www.google.com/maps/search/?api=1&query=" + this.latitude + "," + this.longitude, "_blank");
    }
  }

  findUPRN() {
    console.log(this.adrec);
    console.log("status = " + this.chkcomm);

    console.log("qpost = " + this.qpost);

    if (this.adrec==='') {
      console.log("adrec is null");
      return;
    }

    let comm  = "1";
    if (this.chkcomm == false || (this.chkcomm == undefined)) {
      console.log("chkcomm not checked");
      comm = "0";
    }

    this.getUPRN(this.adrec, comm, this.qpost);
  }

  Test(file: string) {
    const blob = new Blob([file], {type: 'text/csv'}); // you can change the type
    const url = window.URL.createObjectURL(blob);
    window.open(url);
  }

  getUPRN(adrec: string, comm: string, qpost: string) {
    this.jsondata = "";
    this.UPRNService.getUPRNStuff(adrec, comm, qpost).
      subscribe(
        result => {
          this.processUPRN(result);
     },
    error => {
      this.log.error('Unable to process address');
      this.reportComplete = true;
    }
  )
  }

  processUPRN(activityData: any[]) {

    console.log(JSON.stringify(activityData));
    this.jsondata = JSON.stringify(activityData);

    let jsonObj = JSON.parse(JSON.stringify(activityData));
    let u: string = jsonObj.UPRN;
    let classcode = jsonObj.Classification;
    let classterm = jsonObj.ClassTerm;
    let qualifier = jsonObj.Qualifier;

    let building = "?"; let flat = "?"; let number = "?"; let street = "?"; let town = "?"; let postcode = "?";
    let matchpcode = "?"; let matchnumber = "?"; let matchbuilding = "?"; let matchflat = "?";
    let organisation = "?";

    let algorithm = jsonObj.Algorithm;

    if (jsonObj.hasOwnProperty('ABPAddress')) {
      flat = jsonObj.ABPAddress["Flat"];
      number = jsonObj.ABPAddress["Number"];
      street = jsonObj.ABPAddress["Street"];
      building = jsonObj.ABPAddress["Building"];
      town = jsonObj.ABPAddress["Town"];
      postcode = jsonObj.ABPAddress["Postcode"];
      organisation = jsonObj.ABPAddress["Organisaton"]; // spelt wrong in m code
    }

    if (jsonObj.hasOwnProperty('Match_pattern')) {
      matchpcode = jsonObj.Match_pattern["Postcode"];
      matchnumber = jsonObj.Match_pattern["Number"];
      matchflat = jsonObj.Match_pattern["Flat"];
      matchbuilding = jsonObj.Match_pattern["Building"];
    }

    this.UPRNData = activityData;
    this.UPRN = u; this.number = number; this.flat = flat; this.building = building;
    this.town =town; this.street = street; this.postcode = postcode; this.classcode = classcode; this.classterm = classterm;
    this.organisation = organisation;

    console.log("org: "+ this.organisation);

    this.matchpcode=matchpcode; this.matchnumber = matchnumber; this.matchflat= matchflat; this.matchbuilding = matchbuilding;

    this.algorithm = algorithm; this.qualifier = qualifier;

    this.onClickDownGoogleMaps(this.UPRN,"");
  }
}

