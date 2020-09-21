import { Injectable } from '@angular/core';
import {Observable} from "rxjs/Observable";
import {HttpClient, HttpParams} from "@angular/common/http";
import {environment} from "../../environments/environment";

@Injectable()
export class UPRNService {

  SERVER_URL: string = `${environment.apiUrl}`;

  constructor(private http: HttpClient) { }

  getSessionId(): Observable<any> {
    return this.http.get<any[]>(this.SERVER_URL + 'api/sessionid');
  }

  getActivity(userid: string): Observable<any> {
    let params = new HttpParams({fromString: 'u='+userid});
    return this.http.get<any[]>(this.SERVER_URL + 'api/activity?',{params});
  }

  getUPRNI(uprn: string): Observable<any> {
    let params = new HttpParams({fromString: 'uprn='+uprn});
    return this.http.get<any[]>(this.SERVER_URL + 'api/getuprn?',{params});
  }

  getUPRNStuff(adrec: string): Observable<any> {

    let params = new HttpParams({fromString: 'adrec='+adrec});

    console.log("just about to call getinfo "+adrec);
    console.log('adrec: '+params.get('adrec'));
    console.log('test: '+params.get('test'));

    return this.http.get<any[]>(this.SERVER_URL + 'api/getinfo?',{params});
  }

  public upload(formData) {

    return this.http.post<any>(this.SERVER_URL+"api/upload", formData, {
      reportProgress: true,
      observe: 'events'
    });
  }

  downloadFile2(filename: string, userid: string): Observable<Blob> {
    let params = new HttpParams({fromString: 'filename='+filename+"&userid="+userid});

    console.log('filename: '+params.get('filename'));
    return this.http.get<Blob>(this.SERVER_URL+"api/filedownload2?",{params});
  }

  async getRegistration(userid: string) {
    let params = new HttpParams({fromString: 'userid='+userid});
    let x = await this.http.get(this.SERVER_URL + 'api/getreg?',{params}).toPromise();
    return JSON.stringify(x);
  }

  async postRegistration (name: string, org: string, userid: string) {
    let formData = new FormData();
    formData.append('name', name);
    formData.append('organisation', org);
    formData.append('userid', userid);

    let x = await this.http.post(this.SERVER_URL+"api/register", formData).toPromise();

    let jsonObj = JSON.parse(JSON.stringify(x));
    console.log(jsonObj.status);
    return jsonObj.status;
  }

  postFile(files: FileList, userid: string) {

    let fileToUpload = files.item(0);
    let formData = new FormData();

    formData.append('file', fileToUpload, fileToUpload.name);
    formData.append('userid', userid);

    this.http.post<any>(this.SERVER_URL+"api/fileupload2", formData).subscribe((val) => {
      this.processval(val);
      console.log(val);
      return val;
    });
    return "?";
  }

  processval(val)
  {
    if (val.upload["status"] == 'OK') {
      alert("To check progress, click on 'Downloads + activity' tab");
    }
    if (val.upload["status"] == 'NOK') {
      alert('Incorrect file format - please make sure the file you are uploading is tab delimited, and each row contains a numeric identifier');
    }
  }

}
