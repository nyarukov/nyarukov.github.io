---
title: "ARMv7 UBOOT Start.s文件分析"
date: 2022-12-24T11:30:03+00:00
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

# ARMv7 UBOOT Start.s文件分析

```c
reset:
	/* Allow the board to save important registers */
	b	save_boot_params
```

1. 由 **reset**函数跳转到 **save_boot_params **函数。
2. **b:** 跳转不返回。
3. **bl:** 跳转返回 (提前将下一条指令存入 **lr **寄存器，在执行玩当前函数后会执行 **mov pc, lr** ,跳回 **lr **寄存器保存的地址）。

```c
ENTRY(save_boot_params)
	b	save_boot_params_ret		@ back to my caller
ENDPROC(save_boot_params)
	.weak	save_boot_params
```

1. 这个函数实际跳转到 **save_boot_params_ret** 函数。
2. **ENTRY** 宏展开得(**.type save_boot_params STT_FUNC**), **.type \**是 \*\*GCC\*\* 伪指令，说明\**save_boot_param**s是函数。
3. **ENDPROC **宏展开得 (**size save_boot_params, -save_boot_params**)，由当前地址减去标号地址，计算 **save_boot_params **函数大小。
4. **.weak** 关键字，说明后面的 **save_boot_params **为弱标号，如果链接器在其他地方发现 **save_boot_params **，则这里作废，如果没有发现，则使用这里的。

```c
save_boot_params_ret:
	/*
	 * disable interrupts (FIQ and IRQ), also set the cpu to SVC32 mode,
	 * except if in HYP mode already
	 */
	mrs	r0, cpsr
	and	r1, r0, #0x1f		@ mask mode bits
	teq	r1, #0x1a		@ test for HYP mode
	bicne	r0, r0, #0x1f		@ clear all mode bits
	orrne	r0, r0, #0x13		@ set SVC mode
	orr	r0, r0, #0xc0		@ disable FIQ and IRQ
	msr	cpsr,r0
```

1. 将 **cpsr** 状态寄存器存入 **r0**
2. 将寄存器 **r0** 中的值与 **0X1F** 进行与运算,结果保存到 **r1** 寄存器中,提取cpsr寄存器的低5位，用来设置 **CPU ** 模式
3. 判断 **CPU ** 当前是否处于 **HYP** 模式
4. 如果 **CPU ** 不是 **HYP** 模式，则清楚 **r0** 低5位
5. 将 **CPU ** 切换到 **SVC32** 模式， **CPU** 可以使用 **SoC** 的各种资源
6. 关闭 **FIQ** 和 **IRQ**，为了保证 **uboot** 启动过程不允许被打断
7. 将 **r0** 的值存回 **cpsr** 寄存器

```c
#if !(defined(CONFIG_OMAP44XX) && defined(CONFIG_SPL_BUILD))
	/* Set V=0 in CP15 SCTLR register - for VBAR to point to vector */
	mrc	p15, 0, r0, c1, c0, 0	@ Read CP15 SCTLR Register
	bic	r0, #CR_V		@ V = 0
	mcr	p15, 0, r0, c1, c0, 0	@ Write CP15 SCTLR Register

	/* Set vector address in CP15 VBAR register */
	ldr	r0, =_start
	mcr	p15, 0, r0, c12, c0, 0	@Set VBAR
#endif
	/* the mask ROM code should have PLL and others stable */
#ifndef CONFIG_SKIP_LOWLEVEL_INIT
	bl	cpu_init_cp15
	bl	cpu_init_crit
#endif
```

断**CONFIG_OMAP44XX** 和 **CONFIG_SPL_BUILD** 条件是否成立，成立

1. 读取 **CP15** 中 **c1** 的 **c0** 值到 **r0** 寄存器

2. **CR_V**在 **system.h** 中定义=(**1«13**),清除 **r0** 第 **13** 位, **V** 位位 **0** ，异常向量表地址为 **0x00000000** ，为 **1** ：将异常向量表映射到 **0xFFFF0000**

   ![/home/nyaruko/.config/Typora/typora-user-images/image-20221224222525461.png](https://nyarukov.github.io/home/nyaruko/.config/Typora/typora-user-images/image-20221224222525461.png)

3. 将 **r0** 的值写回 **CP15** 中

4. 将 **_start**(异常向量表),标号地址存入 **r0**

5. 将 **r0** 的值写入 **CP15** 的 **c12** **c0** 寄存器中, **VBAR** (向量控制寄存器)

6. 跳转到 **cpu_init_cp15**

   ```c
   ENTRY(cpu_init_cp15)
   	/*
   	 * Invalidate L1 I/D
   	 */
   	mov	r0, #0			@ set up for MCR
   	mcr	p15, 0, r0, c8, c7, 0	@ invalidate TLBs
   	mcr	p15, 0, r0, c7, c5, 0	@ invalidate icache
   	mcr	p15, 0, r0, c7, c5, 6	@ invalidate BP array
   	mcr     p15, 0, r0, c7, c10, 4	@ DSB
   	mcr     p15, 0, r0, c7, c5, 4	@ ISB
   
   	/*
   	 * disable MMU stuff and caches
   	 */
   	mrc	p15, 0, r0, c1, c0, 0
   	bic	r0, r0, #0x00002000	@ clear bits 13 (--V-)
   	bic	r0, r0, #0x00000007	@ clear bits 2:0 (-CAM)
   	orr	r0, r0, #0x00000002	@ set bit 1 (--A-) Align
   	orr	r0, r0, #0x00000800	@ set bit 11 (Z---) BTB
   #ifdef CONFIG_SYS_ICACHE_OFF
   	bic	r0, r0, #0x00001000	@ clear bit 12 (I) I-cache
   #else
   	orr	r0, r0, #0x00001000	@ set bit 12 (I) I-cache
   #endif
   	mcr	p15, 0, r0, c1, c0, 0
   		mov	pc, r5			@ back to my caller
   ENDPROC(cpu_init_cp15)
   ```

   1. 将 **r0** 清 **0**

   2. 将 **r0** 存入 **c8 c7** 中，使 **TLB** 无效， **TLB** 虚拟内存管理

   3. 使 **ICache** 无效

   4. 使分支预测无效

   5. 对于多核 **CPU** 进行数据同步

   6. 清空流水线

   7. 读取 **CP15** 中 **c1** **c0** 值到 **r0** 寄存器

      ![/home/nyaruko/.config/Typora/typora-user-images/image-20221224222525461.png](https://nyarukov.github.io/home/nyaruko/.config/Typora/typora-user-images/image-20221224222525461.png)

   8. 清除第 **13** 位，异常向量表：**0x00000000**

   9. 将 **2:0 (-CAM)** 清零

      0.**Enable the MMU**

      1.**Alignment check enable** 对齐检查

      2.**Cache enable** 数据和统一的Cache

   10. 使能对齐检查模式

   11. 使能分支预测

       **#ifdef** **CONFIG_SYS_ICACHE_OFF** 因 **ICache** 不关，进行 **else** 下语句

   12. 指令 **Cache** 使能

   13. 将 **r0** 写回 **CP15** 中 **c1** **c0**

   14. 跳回主函数

```c
#ifndef CONFIG_SKIP_LOWLEVEL_INIT
	bl	cpu_init_cp15
	bl	cpu_init_crit
#endif
```

1. 跳入 **cpu_init_crit**

```c
ENTRY(cpu_init_crit)
	/*
	 * Jump to board specific initialization...
	 * The Mask ROM will have already initialized
	 * basic memory. Go here to bump up clock rate and handle
	 * wake up conditions.
	 */
	b	lowlevel_init		@ go setup pll,mux,memory lowlevel_init
ENDPROC(cpu_init_crit)
```

1. 跳入 **lowlevel_init**
