---
title: "Uboot移植之编写自己的boot程序"
date: 2022-12-11T11:30:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["first"]
author: "nyaruko"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "Desc Text."
canonicalURL: "https://canonical.url/to/page"
disableHLJS: true # to disable highlightjs
disableShare: false
disableHLJS: false
hideSummary: false
searchHidden: true
ShowReadingTime: true
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowWordCount: true
ShowRssButtonInSectionTermList: true
UseHugoToc: true
cover:
    image: "<image path/url>" # image path/url
    alt: "<alt text>" # alt text
    caption: "<text>" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: true # only hide on current single page
editPost:
    URL: "https://github.com/<path_to_repo>/content"
    Text: "Suggest Changes" # edit text
    appendFilePath: true # to append file path to Edit link
---

# 编译、链接、汇编过程
> 注意 ！，本开发板为正点原子IMX6ULL_Mini开发板,不同点为程序链接地址不同
>

## 预编译(Precompile)

将头文件、宏的值展开带到程序里

## 编译 (Compile)

main.c → main.s

## 汇编(Assembly)

main.s→main.o

## 链接(Link)

将多个xxx.o文件拼接起来，链接成不带后缀的main(ELF)文件

此文件在Linux中可直接运行，但是在单片机中还需要生成为二进制文件

## 生成二进制文件

将main(ELF)中的无用信息剥离，变为main.bin

# 编写boot

第一个我们要进行汇编。把mystart.s变成mystart.o。把mylowleve变成mylowleve.o
进行链接。是把这两个文件统合。我们把他起个名字叫myboot这个文件是elf格式的。
生成二进制文件，把myboot中的段信息，调试信息去掉，变为myboot.bin
制作镜像，使用正点原子提供的**(imxdownload)，将myboot.bin变为myboot.imx**并烧录到SD卡中

## mystart.s	

```c
b reset 
b reset
b reset
b reset
b reset
b reset
b reset
b reset

reset:
    bl gpio_out
    bl led_on 
    mov r0, r1 //跳过流水线
    mov r1, r2//跳过流水线
    mov r2, r3//跳过流水线
    mov r3, r4//跳过流水线
    mov r4, r5//跳过流水线

1:
    b 1b //死循环
gpio_out:
    /* 1、使能所有时钟 */
	ldr r0, =0X020C4068 	/* CCGR0 */
	ldr r1, =0XFFFFFFFF  
	str r1, [r0]		
ldr r0, =0X020C406C  	/* CCGR1 */
str r1, [r0]

ldr r0, =0X020C4070  	/* CCGR2 */
str r1, [r0]

ldr r0, =0X020C4074  	/* CCGR3 */
str r1, [r0]

ldr r0, =0X020C4078  	/* CCGR4 */
str r1, [r0]

ldr r0, =0X020C407C  	/* CCGR5 */
str r1, [r0]

ldr r0, =0X020C4080  	/* CCGR6 */
str r1, [r0]
/* 2、设置GPIO1_IO03复用为GPIO1_IO03 */
ldr r0, =0X020E0068	    /* 将寄存器SW_MUX_GPIO1_IO03_BASE加载到r0中 */
ldr r1, =0X5		              /* 设置寄存器SW_MUX_GPIO1_IO03_BASE的MUX_MODE为5 */
str r1,[r0]

/* 3、配置GPIO1_IO03的IO属性	
 *bit 16:0 HYS关闭
 *bit [15:14]: 00 默认下拉
 *bit [13]: 0 kepper功能
 *bit [12]: 1 pull/keeper使能
 *bit [11]: 0 关闭开路输出
 *bit [7:6]: 10 速度100Mhz
 *bit [5:3]: 110 R0/6驱动能力
 *bit [0]: 0 低转换率
 */
ldr r0, =0X020E02F4	    /*寄存器SW_PAD_GPIO1_IO03_BASE */
ldr r1, =0X10B0
str r1,[r0]

/* 4、设置GPIO1_IO03为输出 */
ldr r0, =0X0209C004	    /*寄存器GPIO1_GDIR */
ldr r1, =0X0000008		
str r1,[r0]
mov pc ,lr //从子程序返回
```

## mylowleve.s

```c
.global led_on
led_on:
	/* 打开LED0

设置GPIO1_IO03输出低电平
*/
ldr r0, =0X0209C000	/*寄存器GPIO1_DR */
ldr r1, =0		
str r1,[r0]
mov pc,lr //从子程序返回
```

## 进行汇编

```
arm-linux-gnueabihf-as mystart.s -o mystart.o
```

![](https://nyarukov.gitee.io/cdn/images/linux/uboot/2.png)

```
arm-linux-gnueabihf-as mylowleve.s -o mylowleve.o
```

![](https://nyarukov.gitee.io/cdn/images/linux/uboot/3.png)

也可以用

```
arm-linux-gnueabihf-gcc -c mystart.s
```

arm-linux-gnueabihf-gcc会在内部判断当前文件是为xxx.s而调用arm-linux-gnueabihf-as

# xxx.o文件内部

> 包含三个段
> .text //代码段
>
> .data //初始化的全局变量
>
> .bss //未初始化，系统自动设置为0
>

## 举个梨子

### 创建main.c文件

```c
long a[3] = {1,2,3};

int main()  {
    return 0;
}
```

### 编译

```bash
arm-linux-gnueabihf-gcc -c main.c 
```

![](https://nyarukov.gitee.io/cdn/images/linux/uboot/4.png)

### 查看xxx.o文件

```
arm-linux-gnueabihf-size main.o
```

![](https://nyarukov.gitee.io/cdn/images/linux/uboot/5.png)

- text表示代码长度为16
- data表示初始化的变量为12（long为4字节，3各元素12个字节）
- bss为0
- dec为10进制
- hex为16进制

### 改变main.c文件

```c
long a[3] = {0};

int main()  {
    return 0;
}
```

### 再次编译查看

![](https://nyarukov.gitee.io/cdn/images/linux/uboot/6.png)


此时data为0，而bss为12，这就是data与bss的区别

# 链接

## 大致流程

​	**将 .text 与 .text 段链接在一起**

​	**将 .data 与 .data 段链接在一起**

​	**将 .bss 与 .bss 亿链接在一起**

![](https://nyarukov.gitee.io/cdn/images/linux/uboot/1.png)

## 建立myboot.lds文件

```
SECTIONS
{
        . = 0X87800000;
        .text : {
                mystart.o 
                * (.text)      
        }
        .data : {
                * (.data)
        }
        .bss_start =  . ;
        .bss : {
                * (.bss)
        }
        .bss_end = . ;
}

```

## 使用命令链接

```
 arm-linux-gnueabihf-ld -Tmyboot.lds -o myboot mystart.o mylowleve.o
```

![](https://nyarukov.gitee.io/cdn/images/linux/uboot/7.png)myboot 就是我们生成的ELF文件

将myboot(ELF)转换为myboot.bin

```
arm-linux-gnueabihf-objcopy -O binary myboot myboot.bin
```

# ![](https://nyarukov.gitee.io/cdn/images/linux/uboot/9.png)烧录

使用正点原子的imxdownload工具将myboot.bin文件烧录到SD卡中


![](https://nyarukov.gitee.io/cdn/images/linux/uboot/11.png)将sd卡插入开发板中，拨码拨到sd卡启动，上电，可以看到开发板的LED被电亮

![](https://nyarukov.gitee.io/cdn/images/linux/uboot/10.jpg)
