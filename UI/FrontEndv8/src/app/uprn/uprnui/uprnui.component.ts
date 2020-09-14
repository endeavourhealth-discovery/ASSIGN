import {Component, OnInit, ViewChild, ElementRef} from '@angular/core';
import {UPRNService} from "../uprn.service";
import {GenericTableComponent, ItemLinkageService, LoggerService, UserManagerService} from "dds-angular8";
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
// npm install @types/file-saver --save-dev
import {saveAs as importedSaveAs} from "file-saver";
import { MatTabChangeEvent } from '@angular/material';

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
  @ViewChild("fileUpload", {static: false}) fileUpload: ElementRef;files  = [];
  adrec: string;
  jsondata: string;
  jsonlatlong: string;

  Latitude: String;
  Longitude: String;

  userId: string;
  reportComplete = true;
  UPRNData: any[];

  UPRN: String;
  number: String;
  flat: String;
  street: String;
  town: String;
  postcode: String;
  classcode: String;
  classterm: String;

  matchpcode: String;
  matchnumber: String;
  matchbuilding: String;
  matchflat: String;

  algorithm: String;

  sessionId: any;
  filetoupload: string;
  HTML: any;
  arrActivity: string [];
  building: string;

  options = {
    fieldSeparator: ',',
    quoteStrings: '"',
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
              private router: Router,) { }

  ngOnInit() {
    // need to call the api here to get a session id
    // tickle the server
    //this.getSess();
    //console.log(this.sessionId);

    //this.HTML = "<html><br><b><u>test</u></b></html>";
    //this.HTML = "<br><br><table border='1'><td>test 1</td><td>test2</td><tr><td>test3</td><td>test4</td></tr></table>";
    this.HTML = "<br><br><b>no activity recorded</b>";

    //this.sessionId = "1";
    this.userManagerService.onProjectChange.subscribe(active => {
    this.activeProject = active;
      this.roleChanged();
    });

    console.log("user id? "+this.activeProject.userId+ " "+this.activeProject.organisationId);
    this.userId=this.activeProject.userId;
    // log some activity
  }

  getSess() {
    this.UPRNService.getSessionId().
    subscribe(
      result => {
        this.processSession(result);
      },
      error => {
        this.log.error('Unable to get session');
      }
    )

    console.log("user id? "+this.userId);

    /*
    const result = this.UPRNService.getSessionId().toPromise();
    console.log(result);
    let jsonObj = JSON.parse(JSON.stringify(result));
    let u: string = jsonObj.name;
    this.sessionId = u;
    */
  }

  processSession(sessionData: any[])
  {
    console.log(sessionData);
    let jsonObj = JSON.parse(JSON.stringify(sessionData));
    this.sessionId = jsonObj.session;
    console.log(this.sessionId);

    this.HTML = "<b>session:</b> "+this.sessionId;
  }

  download(p: String) {
    // this.service.downloadFile("test.csv");

    console.log(this.filetoupload);

    //this.UPRNService.downloadFile2(this.filetoupload).subscribe(blob => {
    //    importedSaveAs(blob, this.filetoupload);
    //  }
    //)

    this.UPRNService.downloadFile2(this.filetoupload, this.userId).subscribe(data => saveAs(data, this.filetoupload));

  }

  roleChanged() {


    if (this.activeProject.applicationPolicyAttributes.find(x => x.applicationAccessProfileName == 'Super User') != null) {
      this.userId = null;
    } else {
      this.userId = this.activeProject.userId;
    }

    //this.getAvailableReports();
  }

  /*
  organisationClicked(repData: ReportData) {
    window.open('#/organisation/' + repData.orgUUID + '/edit');
  }
  */

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

  private uploadFiles() {
    this.fileUpload.nativeElement.value = '';
    this.files.forEach(file => {
      this.uploadFile(file);
    });
  }

  onClickUpload()
  {
    console.log("Upload stuff");
    const fileUpload = this.fileUpload.nativeElement;fileUpload.onchange = () => {
    for (let index = 0; index < fileUpload.files.length; index++)
    {
      const file = fileUpload.files[index];
      this.files.push({ data: file, inProgress: false, progress: 0});
    }
    this.uploadFiles();
  };
    fileUpload.click();
  }

  onClickGoogleMaps()
  {
    //alert("google maps");
    //window.open('#/organisation/' + repData.orgUUID + '/edit');

    //window.open('https://www.google.com/maps/search/?api=1&query=58.698017,-152.522067',"_blank");

    // https://www.google.com/maps/search/?api=1&query=47.5951518,-122.3316393

    // window.open('https://www.google.com/maps/search/?api=1&query=51.5135848,-.0481910',"_blank");
    // window.open('https://www.google.com/maps/search/?api=1&query=535533.00,181212.00',"_blank");

    //window.open('https://www.google.com/maps/search/?api=1&query=51.5338247,-0.1776856',"_blank"); // mumps API returns -.1776856

    window.open("https://www.google.com/maps/search/?api=1&query="+this.Latitude+","+this.Longitude,"_blank");
  }

  onClickDownloadTable(filetodownload: string)
  {
    alert(filetodownload);
    this.filetoupload = filetodownload;
    this.onClickDownload();
  }

  onClickDownload() {
    console.log(this.filetoupload);
    console.log("Download stuff");

    this.HTML = "<br>clicked download";

    console.log("?????? "+this.userId);

    this.UPRNService.downloadFile2(this.filetoupload, this.userId).subscribe(
      result => {
        this.processIT(result);
      },
      error => {
        this.log.error('Unable to perform download');
      }
    );
  }

  // test
  processIT(csvdata: Blob)
  {
    //var csvdata = '[{"name":"test","DOB":"test"},{"name":"test2","DOB":"test2"}]';

    let file = this.filetoupload.split("/", 4);

    //console.log(file);
    //console.log("file: "+file[3]);
    let out = file[3]+"-output";

    //new ngxCsv(csvdata, 'test', this.options);
    new ngxCsv(csvdata, out, this.options);
  }

  onItemLabelLoaded(event) {
      this.sessionId = "1";
      //alert(event);
  }

  onClicky(event) {
    event.target.value=''
  }

  postMethod(files: FileList) {
    this.filetoupload = String(files.item(0).name);
    console.log(this.filetoupload);

    let ret = this.UPRNService.postFile(files, this.userId);

    //alert(ret);
  }

  onActivityRefresh() {

    //let data = "[{\"DT\":\"?\",\"A\":\"?\"}]";
    //this.arrActivity = JSON.parse(data)

    this.UPRNService.getActivity(this.userId).subscribe(
      data => {
        this.arrActivity = data as string[];
      },
      error => {
        this.log.error('Unable to get refresh activity');
      }
    )

  }

  tabChanged(tabChangeEvent: MatTabChangeEvent): void {

    //console.log('tabChangeEvent => ', tabChangeEvent);
    //console.log('index => ', tabChangeEvent.index);

    // Activity tab
    if (tabChangeEvent.index==2) {
      console.log("call the activity interface");

      // this.getSess();

      //let data = "[{\"ID\": \"001\",\"Name\": \"Eurasian Collared-Dove\",\"Type\": \"Dove\",\"Scientific Name\": \"Streptopelia\"},{\"ID\": \"002\",\"Name\": \"Bald Eagle\",\"Type\": \"Hawk\",\"Scientific Name\": \"Haliaeetus leucocephalus\"},{\"ID\": \"003\",\"Name\": \"Cooper's Hawk\",\"Type\": \"Hawk\",\"Scientific Name\": \"Accipiter cooperii\"}]";
      let data = "[{\"DT\":\"?\",\"A\":\"?\"}]";
      this.arrActivity = JSON.parse(data);

      this.UPRNService.getActivity(this.userId).subscribe(
        data => {
          this.arrActivity = data as string[];
        },
      error => {
        this.log.error('Unable to get activity');
      }
      )

      console.log(this.arrActivity);
    }

  }

  onClickJSON() {
    if (this.jsonlatlong == undefined) {
      this.jsonlatlong = "Click on Google maps";
    }
    alert(this.jsonlatlong);
  }

  onClickDownGoogleMaps(uprn: string) {
    // api/getuprn
    this.Longitude=""; this.Latitude="";
    this.UPRNService.getUPRNI(uprn).
      subscribe(
        result => {
          this.processCoord(result);
        },
      error => {
        this.log.error('Unable to process uprn');
        this.reportComplete = true;
      }
    )
  }

  processCoord(activityData: any[]) {
    console.log(JSON.stringify(activityData));
    this.jsonlatlong = JSON.stringify(activityData);

    let jsonObj = JSON.parse(JSON.stringify(activityData));
    let lat = jsonObj.Latitude;
    let long = jsonObj.Longitude;

    this.Latitude = lat;
    this.Longitude = long;

    window.open("https://www.google.com/maps/search/?api=1&query="+this.Latitude+","+this.Longitude,"_blank");
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

    //this.UPRNData.map<UPRNData>(({UPRN}) => JSON.parse(JSON.stringify(activityData)));

    let jsonObj = JSON.parse(JSON.stringify(activityData));
    let u: string = jsonObj.UPRN;
    let classcode = jsonObj.Classification;
    let classterm = jsonObj.ClassTerm;

    let building = "?";
    let flat = "?";
    let number = "?";
    let street = "?";
    let town = "?";
    let postcode = "?";

    let matchpcode = "?";
    let matchnumber = "?";
    let matchbuilding = "?";
    let matchflat = "?";

    let algorithm = jsonObj.Algorithm;

    console.log(jsonObj.hasOwnProperty('ABPAddress'));

    if (jsonObj.hasOwnProperty('ABPAddress')) {
      console.log("here");
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

    console.log(number);

    this.UPRNData = activityData;
    this.UPRN = u;
    this.number = number;
    this.flat = flat;
    this.building = building;
    this.town =town;
    this.street = street;
    this.postcode = postcode;
    this.classcode = classcode;
    this.classterm = classterm;

    this.matchpcode=matchpcode;
    this.matchnumber = matchnumber;
    this.matchflat= matchflat;
    this.matchbuilding = matchbuilding;

    this.algorithm = algorithm;
  }
}

