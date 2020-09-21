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

  lf: string = "[lf]";
  tab: string = "[tab]";

  stuff: any;

  adrec: string;
  jsondata: string;
  jsonlatlong: string;

  wName: string; wOrganisation: string; wRegDate: string;

  latitude: string; longitude: string; qualifier: string; xcoordinate: string; ycoordinate: string; pointcode: string;

  userId: string;
  reportComplete = true;
  UPRNData: any[];

  downloads: string;

  UPRN: string; number: string; flat: string; street: string; town: string; postcode: string; classcode: string; classterm: string;
  dogsEnabled: string;

  matchpcode: string; matchnumber: string; matchbuilding: string; matchflat: string;

  algorithm: string;

  sessionId: any;
  filetoupload: string;
  HTML: any;
  arrActivity: string [];
  building: string;

  selectedIndex: any;

  options = {
    fieldSeparator: ',',
    quotestrings: '"',
    decimalseparator: '.',
    showLabels: true,
    headers: ['ID,UPRN,add_format,alg,class,match_build,match_flat,match_number,match_postcode,match_street,abp_number,abp_postcode,abp_street,abp_town,qualifier,add_candidate'],
    showTitle: false,
    title: 'UPRN',
    useTextFile: false,
    useBom: false,
  };

  public activeProject: UserProject;

  constructor(private UPRNService: UPRNService,
              private userManagerService: UserManagerService,
              private log: LoggerService,
              private itemLinkageService: ItemLinkageService,
              private datePipe: DatePipe,
              private router: Router,
  ) {
  }

  ngOnInit() {
    this.dogsEnabled = "1";
    this.selectedIndex = 0;

    this.downloads = "1";

    this.userManagerService.onProjectChange.subscribe(active => {
      this.activeProject = active;
      this.roleChanged();
    });

    console.log("user id? " + this.activeProject.userId + " " + this.activeProject.organisationId);
    this.userId = this.activeProject.userId;

    this.getRegistration(this.userId);
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
    alert(filetodownload);
    this.filetoupload = filetodownload;
    this.onClickDownload();
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

  async getRegistration(userid: string) {
    let j = await this.UPRNService.getRegistration(this.activeProject.userId);
    let jsonObj = JSON.parse(j);

    console.log(jsonObj.name);
    if (jsonObj.name != "?") {
      this.wName = jsonObj.name;
      this.wOrganisation = jsonObj.organization;
      this.wRegDate = jsonObj.regdate;
    }

    if (jsonObj.name == "?") {
      // switch to Welcome tab
      this.dogsEnabled = "";
      this.selectedIndex = 4;
    }
  }

  async onClickAgree(wname: string, worg: string) {

    //this.tabs.splice(0, 1);

    if (wname == undefined || (worg == undefined)) {
      alert("Please enter your Name and Organisation");
      return;
    }

    this.stuff = await this.UPRNService.postRegistration(wname, worg, this.userId);

    if (this.stuff == "OK") {
      //alert("Registration filed OK");
      this.dogsEnabled = "1";
      this.selectedIndex = 0;
    }
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

    this.getUPRN(this.adrec);
  }

  getUPRN(adrec: string) {
    this.jsondata = "";
    this.UPRNService.getUPRNStuff(adrec).
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

    let algorithm = jsonObj.Algorithm;

    if (jsonObj.hasOwnProperty('ABPAddress')) {
      flat = jsonObj.ABPAddress["Flat"];
      number = jsonObj.ABPAddress["Number"];
      street = jsonObj.ABPAddress["Street"];
      building = jsonObj.ABPAddress["Building"];
      town = jsonObj.ABPAddress["Town"];
      postcode = jsonObj.ABPAddress["Postcode"];
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

    this.matchpcode=matchpcode; this.matchnumber = matchnumber; this.matchflat= matchflat; this.matchbuilding = matchbuilding;

    this.algorithm = algorithm; this.qualifier = qualifier;

    this.onClickDownGoogleMaps(this.UPRN,"");
  }
}

