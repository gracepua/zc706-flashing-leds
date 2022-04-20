#include <iostream>
#include "xbasic_types.h"
#include "xparameters.h"

void delayToFlash() {
    for(int i=0; i<10000000; i++) {
        int a;
        a++;
    }
}

int main() {

	std::cout << "starting the demo sequence" << std::endl;

	uint32_t ledCtrl_baseAddress;
	Xuint32* ledCtrl_baseAddress_p;
	int c;

	ledCtrl_baseAddress = XPAR_FLASHING_LED_0_S00_AXI_BASEADDR;
	ledCtrl_baseAddress_p = (Xuint32*) ledCtrl_baseAddress;

	for(c=0; c<16; c++) {
		*(ledCtrl_baseAddress_p) = c;
		delayToFlash();
	}

	int b=1;
	for(int d=0; d<4; d++) {
		for(c=0; c<4; c++){
			b = b<<1;
			*(ledCtrl_baseAddress_p) = b;
			delayToFlash();
		}
		for(c=0; c<4; c++){
			b = b>>1;
			*(ledCtrl_baseAddress_p) = b;
			delayToFlash();
		}
	}

	for(c=0; c<8; c++) {
		*(ledCtrl_baseAddress_p) = 0b1010;
		delayToFlash();
		*(ledCtrl_baseAddress_p) = 0b0101;
		delayToFlash();
	}

	*(ledCtrl_baseAddress_p) = 0;
	std::cout << "\nnice job you're done" << std::endl;
	return 0;
}
