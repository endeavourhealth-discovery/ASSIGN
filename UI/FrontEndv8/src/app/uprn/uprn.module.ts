import { NgModule } from '@angular/core';
import {CommonModule, DatePipe} from '@angular/common';
import { UPRNComponent } from './uprnui/uprnui.component';
import {UPRNService} from "./uprn.service";
import {FormsModule} from "@angular/forms";
import {
  MatBadgeModule,
  MatButtonModule,
  MatCardModule,
  MatCheckboxModule,
  MatDialogModule,
  MatDividerModule,
  MatFormFieldModule,
  MatIconModule,
  MatInputModule,
  MatMenuModule,
  MatPaginatorModule,
  MatProgressBarModule,
  MatProgressSpinnerModule,
  MatSelectModule,
  MatSnackBarModule,
  MatSortModule,
  MatTableModule,
  MatTabsModule,
  MatTreeModule
} from "@angular/material";
import {CoreModule, GenericTableModule, ItemLinkageModule} from "dds-angular8";
import {RouterModule} from "@angular/router";
import {FlexModule} from "@angular/flex-layout";
import {BrowserModule} from "@angular/platform-browser";
import {BrowserAnimationsModule} from "@angular/platform-browser/animations";

@NgModule({
  imports: [
    BrowserAnimationsModule,
    BrowserModule,
    CommonModule,
    CoreModule,
    FlexModule,
    FormsModule,
    GenericTableModule, ItemLinkageModule,
    MatBadgeModule, MatButtonModule,
    MatCardModule, MatCheckboxModule,
    MatDialogModule, MatDividerModule,
    MatFormFieldModule,
    MatIconModule, MatInputModule,
    MatMenuModule,
    MatPaginatorModule, MatProgressBarModule, MatProgressSpinnerModule,
    MatSelectModule, MatSnackBarModule, MatSortModule,
    MatTableModule, MatTabsModule, MatTreeModule,
    RouterModule,
  ],
  declarations: [UPRNComponent],
  providers: [
    UPRNService,
    DatePipe
  ]
})
export class UPRNModule { }
