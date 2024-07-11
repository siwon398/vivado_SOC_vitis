#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xgpio.h"
#include "xintc.h"
#include "xiic.h"
#include "xil_exception.h"
#include "xuartlite.h"

//BTN
#define BTN_ID XPAR_AXI_GPIO_0_DEVICE_ID
#define BTN_VEC_ID XPAR_INTC_0_GPIO_0_VEC_ID
#define BTN_CHANNEL 1

//UART
#define UART_ID XPAR_AXI_UARTLITE_0_DEVICE_ID
#define UART_BT_ID XPAR_UARTLITE_1_DEVICE_ID

//INTC
#define INTC_ID XPAR_INTC_0_DEVICE_ID

//JOYSTICK
#define JOYSTICK_ADDR XPAR_MYIP_JOYSTICK_0_S00_AXI_BASEADDR

//LCD
#define IIC_ID XPAR_AXI_IIC_0_DEVICE_ID

//UltraSonic
#define ULT_ADDR XPAR_MYIP_ULTRASONIC_0_S00_AXI_BASEADDR		//ultrasonic address

//PWM 4개
#define PWM_ADDR0 XPAR_MYIP_PWM_0_S00_AXI_BASEADDR
#define PWM_ADDR1 XPAR_MYIP_PWM_1_S00_AXI_BASEADDR
#define PWM_ADDR2 XPAR_MYIP_PWM_2_S00_AXI_BASEADDR
#define PWM_ADDR3 XPAR_MYIP_PWM_3_S00_AXI_BASEADDR


//함수 선언
void BTN_ISR(void *CallBackRef);
void Iic_LCD_write_byte(u8 tx_data, u8 rs);
void Iic_LCD_init(void);
void Iic_movecursor(u8 row, u8 col);
void LCD_write_string(char *string);
void SendHandler(void *CallBackRef, unsigned int EventData);
void RecvHandler(void *CallBackRef, unsigned int EventData);

XGpio btn_device;
XIntc intc;
XUartLite uart_device;
XIic iic_device;

//전역변수 선언
volatile unsigned int *ultrasonic;
volatile unsigned int *joystick;
volatile unsigned int *pwm0;
volatile unsigned int *pwm1;
volatile unsigned int *pwm2;
volatile unsigned int *pwm3;

volatile char Tx[5] = {'clear'};
volatile char Rx[4] = {0};

char btn_int_flag;

#define xdata joystick[0]
#define ydata joystick[1]

#define BL 3
#define EN 2
#define RW 1
#define RS 0

#define COMMAND 0
#define DATA 1

int main()
{
	XGpio_Config *cfg_ptr;
	ultrasonic = (volatile unsigned int *)ULT_ADDR;
	joystick = (volatile unsigned int*)JOYSTICK_ADDR;
	pwm0 = (volatile unsigned int*)PWM_ADDR0;
	pwm1 = (volatile unsigned int*)PWM_ADDR1;
	pwm2 = (volatile unsigned int*)PWM_ADDR2;
	pwm3 = (volatile unsigned int*)PWM_ADDR3;

    init_platform();

    u32 distance = 0;

    XUartLite_Initialize(&uart_device, UART_BT_ID);

    //GPIO 초기화
    cfg_ptr = XGpio_LookupConfig(BTN_ID);
	XGpio_CfgInitialize(&btn_device, cfg_ptr, cfg_ptr->BaseAddress);
	XGpio_SetDataDirection(&btn_device, BTN_CHANNEL, 0b1111);

	XIntc_Initialize(&intc, INTC_ID);
	XIntc_Connect(&intc, BTN_VEC_ID, (XInterruptHandler)BTN_ISR, (void *)&btn_device);

	XIntc_Enable(&intc, BTN_VEC_ID);
	XIntc_Start(&intc, XIN_REAL_MODE);

	XGpio_InterruptEnable(&btn_device, BTN_CHANNEL);
	XGpio_InterruptGlobalEnable(&btn_device);

	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XIntc_InterruptHandler, &intc);
	Xil_ExceptionEnable();

	XUartLite_SetSendHandler(&uart_device, SendHandler, &uart_device);
	XUartLite_SetRecvHandler(&uart_device, RecvHandler, &uart_device);
	XUartLite_EnableInterrupt(&uart_device);

	XIic_Initialize(&iic_device, IIC_ID);
	Iic_LCD_init();

	LCD_write_string("distance :   cm");
	Iic_movecursor(1, 0);

	//pwm_period
	pwm0[1] = pwm1[1] = pwm2[1] = pwm3[1]= 200000;

    while(1){

    	u32 distance = ultrasonic[0];
    	Iic_movecursor(0, 10);
    	Iic_LCD_write_byte('0' + distance/100%10, DATA);
       	Iic_LCD_write_byte('0' + distance/10%10, DATA);
    	Iic_LCD_write_byte('0' + distance%10, DATA);
    	pwm0[0] = pwm1[0] = pwm2[0] = pwm3[0]= 200000;
       	//if문 전에 미리 pwm값 저장
        int original_pwm0 = pwm0[0];
        int original_pwm1 = pwm1[0];
        int original_pwm2 = pwm2[0];
        int original_pwm3 = pwm3[0];

        XUartLite_Send(&uart_device, (u8 *)Tx, 1);

		if(Rx){
			RecvHandler(&uart_device, (u8 *)Rx);
			xil_printf("%c\n\r", *Rx);
			MB_Sleep(1000);
		}

        //조이스틱

        int zone = getZone(xdata, ydata);
        if((pwm0[0] = pwm1[0] = pwm2[0] = pwm3[0]) > 60000){
        switch(zone) {
        	case 1:
        		pwm0[0] = original_pwm0 - 150000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
        	case 2:
                pwm0[0] = original_pwm0 - 100000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 3:
                pwm0[0] = original_pwm0 - 50000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 4:
                pwm0[0] = original_pwm0 - 150000;
                pwm1[0] = original_pwm1 - 150000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 5:
                pwm0[0] = original_pwm0 - 100000;
                pwm1[0] = original_pwm1 - 100000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 6:
                pwm0[0] = original_pwm0 - 50000;
                pwm1[0] = original_pwm1 - 50000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 7:
                pwm1[0] = original_pwm1 - 150000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 8:
                pwm1[0] = original_pwm1 - 100000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 9:
            	pwm0[0] = original_pwm0 - 50000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 10:
                pwm0[0] = original_pwm0 - 150000;
                pwm2[0] = original_pwm2 - 150000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 11:
                pwm0[0] = original_pwm0 - 100000;
                pwm2[0] = original_pwm2 - 100000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 12:
                pwm0[0] = original_pwm0 - 50000;
                pwm2[0] = original_pwm2 - 50000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 13:
                pwm1[0] = original_pwm1 - 150000;
                pwm3[0] = original_pwm3 - 150000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 14:
                pwm1[0] = original_pwm1 - 100000;
                pwm3[0] = original_pwm3 - 100000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 15:
                pwm1[0] = original_pwm1 - 50000;
                pwm3[0] = original_pwm3 - 50000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 16:
                pwm2[0] = original_pwm2 - 150000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 17:
                pwm2[0] = original_pwm2 - 100000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 18:
                pwm2[0] = original_pwm2 - 50000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 19:
                pwm2[0] = original_pwm2 - 150000;
                pwm3[0] = original_pwm3 - 150000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 20:
                pwm2[0] = original_pwm2 - 100000;
                pwm3[0] = original_pwm3 - 100000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 21:
                pwm2[0] = original_pwm2 - 50000;
                pwm3[0] = original_pwm3 - 50000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 22:
                pwm3[0] = original_pwm3 - 150000;
                xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
                break;
            case 23:
               pwm3[0] = original_pwm3 - 100000;
               xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
               break;
            case 24:
               pwm3[0] = original_pwm3 - 50000;
               xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r x :%d, y:%d\n\r", pwm0[0], pwm1[0], pwm2[0], pwm3[0],xdata, ydata);
               break;
            default:
               // Neutral zone
                break;
        }
        }
        //while문 탈출하면 다시 초기화(버튼 상/하 pwm)

        pwm0[0] = original_pwm0;
        pwm1[0] = original_pwm1;
        pwm2[0] = original_pwm2;
        pwm3[0] = original_pwm3;

    	//BTN 상/하

    	xil_printf("1:%d\n\r 2:%d\n\r 3:%d\n\r 4:%d\n\r ", pwm0[0], pwm1[0], pwm2[0], pwm3[0]);
    	if(btn_int_flag){
    	    MB_Sleep(1);
    	    XGpio_InterruptEnable(&btn_device, BTN_CHANNEL);

    	    //상
    	    if(XGpio_DiscreteRead(&btn_device, BTN_CHANNEL) & 0b0001){
    	    	if(pwm0[0] < 200000){
    	    		pwm0[0] += 10000;
    	    	    pwm1[0] += 10000;
    	    	   	pwm2[0] += 10000;
    	    	   	pwm3[0] += 10000;
    	    	}else{
    	    	    pwm0[0] = pwm1[0] = pwm2[0] = pwm3[0]= 200000;
    	    	}
    	    }

    	    //하
    	    else if(XGpio_DiscreteRead(&btn_device, BTN_CHANNEL) & 0b1000){
    	    	if(pwm0[0] > 0){
    	    	    pwm0[0] -= 10000;
    	    	    pwm1[0] -= 10000;
    	    	    pwm2[0] -= 10000;
    	    	    pwm3[0] -= 10000;
    	    	}else{
    	    	    pwm0[0] = pwm1[0] = pwm2[0] = pwm3[0]= 0;
    	    	}
    	    }
    	}
    }
    cleanup_platform();
    return 0;
}
void BTN_ISR(void *CallBackRef){
	btn_int_flag =1;
	XGpio_InterruptClear(&btn_device, BTN_CHANNEL);
	XGpio_InterruptDisable(&btn_device, BTN_CHANNEL);
	return;
}
void Iic_LCD_write_byte(u8 tx_data, u8 rs){
	u8 data_t[4] = {0,};
	data_t[0] = (tx_data & 0xf0) | (1 << BL) | (rs & 1) | (1 << EN);
	data_t[1] = (tx_data & 0xf0) | (1 << BL) | (rs & 1);
	data_t[2] = (tx_data << 4) | (1 << BL) | (rs & 1) | (1 << EN);
	data_t[3] = (tx_data << 4) | (1 << BL) | (rs & 1);
	XIic_Send(iic_device.BaseAddress, 0x27, &data_t, 4, XIIC_STOP);
}
void Iic_LCD_init(void){
	MB_Sleep(15);
	Iic_LCD_write_byte(0x33, COMMAND);
	Iic_LCD_write_byte(0x32, COMMAND);
	Iic_LCD_write_byte(0x28, COMMAND);
	Iic_LCD_write_byte(0x0c, COMMAND);
	Iic_LCD_write_byte(0x01, COMMAND);
	Iic_LCD_write_byte(0x06, COMMAND);
	MB_Sleep(10);
	return;
}
void Iic_movecursor(u8 row, u8 col){
	row %= 2;
	col %= 40;
	Iic_LCD_write_byte(0x80 | (row << 6) | col, COMMAND);
	return;
}
void LCD_write_string(char *string){
	for (int i = 0; string[i]; i++){
		Iic_LCD_write_byte(string[i], DATA);
	}
	return;
}
void SendHandler(void *CallBackRef, unsigned int EventData){
	XUartLite_Send(&uart_device, (u8 *)Tx, 16 );
	return;
}
void RecvHandler(void *CallBackRef, unsigned int EventData){
	    XUartLite_Recv(&uart_device, (u8 *)Rx, 1);
	    xil_printf("%d", *Rx);
	    MB_Sleep(1000);
	return;
}
int getZone(int x, int y) {
    if (x < 20 && y < 20) return 1;
    if (20 <= x && x < 41 && 20 <= y && y < 41) return 2;
    if (41 <= x && x < 62 && 41 <= y && y < 62) return 3;

    if (62 < x && x < 70 && y < 20) return 4;
    if (62 < x && x < 70 && 20 <= y && y < 41) return 5;
    if (62 < x && x < 70 && 41 <= y && y < 62) return 6;

    if (107 < x && y < 20) return 7;
    if (88 <= x && x <= 107 && 20 <= y && y < 41) return 8;
    if (70 <= x && x <= 88 && 41 <= y && y < 62) return 9;

    if (x < 20 && 62 < y && y < 70) return 10;
    if (20 <= x && x < 41 && 62 < y && y < 70) return 11;
    if (41 <= x && x < 62 && 62 < y && y < 70) return 12;

    if (70 < x && x < 88 && 62 < y && y < 70) return 13;
    if (88 <= x && x < 107 && 62 < y && y < 70) return 14;
    if (107 <= x && 62 < y && y < 70) return 15;

    if (x < 20 && 107 < y) return 16;
    if (20 <= x && x < 41 && 88 < y && y <= 107) return 17;
    if (41 <= x && x < 62 && 70 < y && y < 88) return 18;

    if (62 < x && x < 70 && 107 < y) return 19;
    if (62 < x && x < 70 && 88 < y && y <= 107) return 20;
    if (62 < x && x < 70 && 70 < y && y <= 88) return 21;

    if (107 < x && 107 < y) return 22;
    if (88 < x && x <= 107 && 88 < y && y <= 107) return 23;
    if (70 < x && x <= 88 && 70 < y && y <= 88) return 24;

    return 0; // Neutral zone
}
