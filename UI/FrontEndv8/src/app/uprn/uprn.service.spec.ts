import { TestBed, inject } from '@angular/core/testing';

import { UPRNService } from './uprn.service';

describe('UPRNService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [UPRNService]
    });
  });

  it('should be created', inject([UPRNService], (service: UPRNService) => {
    expect(service).toBeTruthy();
  }));
});
