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
#include "xintc.h"
#include "xil_exception.h"

//버튼 ID 생성
#define BTN_ID XPAR_GPIO_0_DEVICE_ID
#define BTN_VEC_ID XPAR_INTC_0_GPIO_0_VEC_ID
#define BTN_CHANNEL 1

//인터럽트 ID 생성
#define INTC_ID XPAR_INTC_0_DEVICE_ID

//스톱워치 ID 생성
#define STOPWATCH_BASEADDR XPAR_MYIP_STOPWATCH_0_S00_AXI_BASEADDR

XGpio btn_device;
XIntc intc;

volatile unsigned int *stopwatch; //전역변수 선언
char btn_int_flag;

void BTN_ISR(void *CallBackRef);

int main()
{
	u32 btn_value =0;

	init_platform();

	print("Start \n\r");

	XGpio_Config *cfg_ptr;

	u16 data =0;

	stopwatch = (volatile unsigned int *)STOPWATCH_BASEADDR;

	cfg_ptr = XGpio_LookupConfig(BTN_ID);
	XGpio_CfgInitialize(&btn_device, cfg_ptr, cfg_ptr->BaseAddress);
	XGpio_SetDataDirection(&btn_device, BTN_CHANNEL, 0b1111);

	XIntc_Initialize(&intc, INTC_ID);
	XIntc_Connect(&intc, BTN_VEC_ID, (XInterruptHandler)BTN_ISR, (void *)&btn_device);

	XIntc_Enable(&intc, BTN_VEC_ID);
	XIntc_Start(&intc, XIN_REAL_MODE);

	XGpio_InterruptEnable(&btn_device, BTN_CHANNEL); //개별
	XGpio_InterruptGlobalEnable(&btn_device);		//글로벌

	Xil_ExceptionInit(); // Microblaze enable 해준거 설정
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XIntc_InterruptHandler, &intc);
	Xil_ExceptionEnable();

    while(1){
    		if(btn_int_flag){
    			btn_int_flag =0;
    			MB_Sleep(1);
    			XGpio_InterruptEnable(&btn_device, BTN_CHANNEL);
    			if(XGpio_DiscreteRead(&btn_device, BTN_CHANNEL) & 0b0001){
    				print("btn btn0 pushed \n\r");
    				stopwatch[0] ^= 0b1;
    			}
    			else if(XGpio_DiscreteRead(&btn_device, BTN_CHANNEL) & 0b0010){
    				print("btn btn1 pushed \n\r");
    				stopwatch[0] ^= 0b10;
    			}
    		}
    }
    cleanup_platform();
    return 0;
}
void BTN_ISR(void *CallBackRef){
	//XGpio *Gpio_ptr = (XGpio *)CallBackRef;
	btn_int_flag =1;
	XGpio_InterruptClear(&btn_device, BTN_CHANNEL);
	XGpio_InterruptDisable(&btn_device, BTN_CHANNEL);
	return;
}
