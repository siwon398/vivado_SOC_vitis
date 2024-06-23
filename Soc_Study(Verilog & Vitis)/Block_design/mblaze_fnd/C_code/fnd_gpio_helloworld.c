/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xgpio.h"

#define FND_ID XPAR_AXI_GPIO_FND_DEVICE_ID
#define SW_ID XPAR_AXI_GPIO_SW_DEVICE_ID
#define FND_COM_CHANNEL 1
#define FND_DATA_CHANNEL 2
#define SW_CHANNEL 1

u32 fnd[16] = {
		0xc0, 0xf9, 0xa4, 0xb0, 0x99, 0x92, 0x82, 0xd8,
		0x80, 0x98, 0x88, 0x83, 0xc6, 0xa1, 0x86, 0x8e};

int main()
{
    init_platform();

    print("Start!!\n\r");

    XGpio_Config *cfg_ptr;
	XGpio fnd_device, sw_device;

	u32 data = 0;
	u32 cnt = 0;

	cfg_ptr = XGpio_LookupConfig(FND_ID);
	XGpio_CfgInitialize(&fnd_device, cfg_ptr, cfg_ptr->BaseAddress);
	XGpio_SetDataDirection(&fnd_device, FND_COM_CHANNEL, 0);

	XGpio_CfgInitialize(&fnd_device, cfg_ptr, cfg_ptr->BaseAddress);
	XGpio_SetDataDirection(&fnd_device, FND_DATA_CHANNEL, 0);

	cfg_ptr = XGpio_LookupConfig(SW_ID);
	XGpio_CfgInitialize(&sw_device, cfg_ptr, cfg_ptr->BaseAddress);
	XGpio_SetDataDirection(&sw_device, SW_CHANNEL, 0xffff);

    while(1){
//    	data = XGpio_DiscreteRead(&sw_device, SW_CHANNEL);
    	data = 1234;
    	int dec = 1;
    	for(char i = 0;i<4;i++){
    		XGpio_DiscreteWrite(&fnd_device, FND_COM_CHANNEL, ~(1<<i));
    		XGpio_DiscreteWrite(&fnd_device, FND_DATA_CHANNEL, fnd[data/dec%10]);
    		dec *= 10;
    		MB_Sleep(1);
    	}

    }

    cleanup_platform();
    return 0;
}








