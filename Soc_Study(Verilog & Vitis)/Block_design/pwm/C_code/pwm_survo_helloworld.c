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

#define PWM_SURVO_BASEADDR XPAR_MYIP_PWM_SURVO_0_S00_AXI_BASEADDR

#define OFF 0
#define ON 1
#define DOWN 0
#define UP 1

#define  PWM_DUTY pwm_survo[0]
#define  PWM_PERIOR pwm_survo[1]
#define  PWM_ON_OFF pwm_survo[2]

int main()
{
    init_platform();

    print("Start!!\n\r");

    volatile unsigned int *pwm_survo = (volatile unsigned int *)PWM_SURVO_BASEADDR;
    PWM_PERIOR = 2000000;
    PWM_ON_OFF = ON;
    PWM_DUTY = 50000;
    char up_down_flag = DOWN;
    int cnt = 0;
    while(1){

    	if(up_down_flag){
    		PWM_DUTY += 1000;
    		if(PWM_DUTY >= 250000)up_down_flag = DOWN;
    	}
    	else {
    		PWM_DUTY -= 1000;
    		if(PWM_DUTY <= 50000)up_down_flag = UP;
    	}
    	MB_Sleep(100);
    	cnt += 1;
    	if(cnt >= 400){
    		cnt = 0;
    		if(PWM_ON_OFF)PWM_ON_OFF = OFF;
    		else PWM_ON_OFF = ON;
    	}


    }

    cleanup_platform();
    return 0;
}
