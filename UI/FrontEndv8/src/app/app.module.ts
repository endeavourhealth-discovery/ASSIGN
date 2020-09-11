import { NgModule, DoBootstrap, ApplicationRef } from '@angular/core';
import { KeycloakAngularModule, KeycloakService } from 'keycloak-angular';
import {AppMenuService} from './app-menu.service';
import {RouterModule} from '@angular/router';
import {HttpClientModule} from '@angular/common/http';
import {
  AbstractMenuProvider,
  LayoutComponent,
  LayoutModule,
  LoggerModule,
  SecurityModule,
  UserManagerModule,
  DialogsModule,
  GenericTableModule
} from 'dds-angular8';

import {UPRNModule} from "./uprn/uprn.module";

const keycloakService = new KeycloakService();

@NgModule({
  imports: [
    KeycloakAngularModule,
    HttpClientModule,
    LayoutModule,
    SecurityModule,
    LoggerModule,
    UserManagerModule,
    GenericTableModule,
    //MySharingModule,
    //ReportingModule,
    DialogsModule,
    //GoogleMapsViewerModule,
    UPRNModule,

    RouterModule.forRoot(AppMenuService.getRoutes(), {useHash: true}),
  ],
  providers: [
    { provide: AbstractMenuProvider, useClass : AppMenuService },
    { provide: KeycloakService, useValue: keycloakService }
  ]
})
export class AppModule implements DoBootstrap {
  ngDoBootstrap(appRef: ApplicationRef) {
    keycloakService
      .init({config: 'public/wellknown/authconfigraw', initOptions: {onLoad: 'login-required', 'checkLoginIframe':false}})
      .then((authenticated) => {
        if (authenticated)
          appRef.bootstrap(LayoutComponent);
      })
      .catch(error => console.error('[ngDoBootstrap] init Keycloak failed', error));
  }
}
