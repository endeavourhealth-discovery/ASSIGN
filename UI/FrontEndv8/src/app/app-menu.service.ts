import {Component, Injectable} from '@angular/core';
import {Routes} from '@angular/router';
import {AbstractMenuProvider, MenuOption} from 'dds-angular8';
import {UPRNComponent} from "./uprn/uprnui/uprnui.component";

@Injectable()
export class AppMenuService implements  AbstractMenuProvider {
  static getRoutes(): Routes {
    return [
      { path: '', redirectTo : 'uprn', pathMatch: 'full' }, // Default route
      //{ path: 'uprn', component: UPRNComponent, data: {role: 'Admin', helpContext: 'UPRN#view'}},
      // breaks localhost
      { path: 'uprn', component: UPRNComponent, data: {role: 'uprn-match:uprn', helpContext: 'UPRN#view'}},
    ];
  }

  getClientId(): string {
    // breaks localhost
    return 'uprn-match';
    // return 'eds-dsa-manager';
  }

  getApplicationTitle(): string {
    return 'uprn-match';
  }

  getMenuOptions(): MenuOption[] {
    return [
      {caption: 'UPRN', state: 'uprn', icon: 'fas fa-file-export'}
    ];
  }
}
