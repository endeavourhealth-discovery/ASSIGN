import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { UPRNComponent } from './uprnui.component';

describe('UPRNComponent', () => {
  let component: UPRNComponent;
  let fixture: ComponentFixture<UPRNComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ UPRNComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(UPRNComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
