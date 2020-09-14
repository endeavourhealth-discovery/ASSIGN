import { Injectable } from '@angular/core';
import {Observable} from "rxjs/Observable";
import {HttpClient, HttpParams} from "@angular/common/http";
import {environment} from "src/environments/environment";

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
    return this.http.get<Blob>(this.SERVER_URL+"api/filedownload?",{params});
  }

  postFile(files: FileList, userid: string) {

    let fileToUpload = files.item(0);
    let formData = new FormData();

    formData.append('file', fileToUpload, fileToUpload.name);
    formData.append('userid', userid);

    this.http.post<any>(this.SERVER_URL+"api/fileupload", formData).subscribe((val) => {

      this.processval(val);
      console.log(val);
      return val;
    });
    return "?";
  }

  processval(val)
  {
    console.log("in process val");
    let x=JSON.stringify(val);
    if (val.upload["status"] == 'OK') {
      alert('File has been successfully posted (to check progress, click on activity tab)');
    }
  }

}
