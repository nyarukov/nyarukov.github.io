---
title: "使用busybox构建根文件系统"
date: 2022-12-30T11:30:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["first"]
author: "nyaruko"
showToc: true
TocOpen: true
draft: false
hidemeta: false
comments: false
description: "Desc Text."
disableHLJS: true # to disable highlightjs
disableShare: false
disableHLJS: true
hideSummary: false
searchHidden: true
ShowReadingTime: true
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowWordCount: true
UseHugoToc: true
---

# 介绍

Linux的根文件系统是指Linux操作系统中最顶层的文件目录。 在Linux中，文件系统是以树状结构进行组织的，根文件系统是整个文件系统的根目录。根文件系统通常称为"/"(前斜杠)。所有其他文件和目录都是根文件系统的子目录。根文件系统包含了Linux操作系统所需的所有文件和目录，包括系统内核、配置文件、库文件、程序和命令行工具等。

常用目录介绍

- /bin - 存放二进制可执行文件，如 ls、grep 等。
- /boot - 存放引导程序和内核相关的文件。
- /dev - 存放设备文件。
- /etc - 存放系统配置文件和启动脚本。
- /home - 存放用户家目录。
- /lib - 存放系统库文件。
- /media - 存放挂载的外部设备，如 USB 闪存盘、CD-ROM 等。
- /mnt - 通常用于挂载其他分区或设备。
- /opt - 可选安装文件的目录，如第三方软件。
- /proc - 存放内存中的信息，如系统进程信息。
- /root - root 用户的家目录。
- /sbin - 存放系统管理员用的二进制可执行文件。
- /tmp - 存放临时文件。
- /usr - 存放可以被多个用户共享的程序和数据。
- /var - 存放可变的数据，如系统日志文件、网站数据等。

## 下载BusyBox。

可以从BusyBox官网（https://www.busybox.net/downloads/）下载最新版的BusyBox源代码。

这里下载1.35.0版本

![](https://nyarukov.gitee.io/cdn/images/linux/busybox/15-24-55.png)

## 配置

### 解压进入目录

```
sudo tar xvf busybox-1.35.0.tar.bz2
cd busybox-1.35.0
```

### busybox 配置选项

- defconfig，默认配置
- allyesconfig，全选配置
- menuconfig，图形化配置

### 使用图形化配置

```
make menuconfig
```

![](https://nyarukov.gitee.io/cdn/images/linux/busybox/15-43-54.png)

### 配置交叉编译器：

Location:

 ->Setting:

 ->Cross compiler prefix

也可以在源码目录中的Makefile文件中添加

```
ARCH ?=arm
CROSS_COMPILE ?=/etc/arm/4.9.4/bin/arm-linux-gnueabihf-
```

![](https://nyarukov.gitee.io/cdn/images/linux/busybox/16-24-20.png)

![](https://nyarukov.gitee.io/cdn/images/linux/busybox/15-45-14.png)

可以使用arm-linux-gnueabihf-gcc -v查看位置

第三行为交叉编译器的位置

```
OLLECT_LTO_WRAPPER=/etc/arm/4.9.4/bin/
```

![](https://nyarukov.gitee.io/cdn/images/linux/busybox/15-47-04.png)

![](https://nyarukov.gitee.io/cdn/images/linux/busybox/15-49-26.png)

### 取消静态库编译

Location: -> Settings -> Build static binary (no shared libs)

![](https://nyarukov.gitee.io/cdn/images/linux/busybox/15-51-17.png)

### 添加vi 命令

Location:

 -> Settings

 -> vi-style line editing commands

根文件中要操作修改文件就需要用到vi这里就必须选中

![](https://nyarukov.gitee.io/cdn/images/linux/busybox/15-51-45.png)

### 取消简化模块

Location:

 ->Linux Module Utilities：

 -> Simplified modutils

![](https://nyarukov.gitee.io/cdn/images/linux/busybox/16-13-44.png)

### 支持mdev

选中mdev及mdev下面的所有选项

Location:

 ->Linux System Utilities

 -> mdev

![](https://nyarukov.gitee.io/cdn/images/linux/busybox/16-14-48.png)

## 编译

```
 make 
 make install 
```

也可以指定编译结果的目录

```
make install CONFIG_PREFIX= <PATH>
```

PATH:路径

## 向根文件系统添加 lib 库

打开编译后的目录

image-20230108162701659

创建lib文件夹

```
sudo mkdir lib 
```

将交叉编译器路径下的libc文件夹里面的库文件拷贝到我们的根文件系统中的lib文件夹中

![https://nyarukov.gitee.io/cdn/images/linux/busybox/16-26-59.png](https://nyarukov.gitee.io/cdn/images/linux/busybox/16-26-59.png)

进入交叉编译器lib库

```
/etc/arm/4.9.4/arm-linux-gnueabihf/libc/lib/
```

拷贝

```
cp *so* *.a /home/nyarukov/Documents/linux/busybox/rootfs -d
```

其中有一个文件是以软连接的方式存在的，所以这里我们需要单独操作一下，

ld-linux-armhf.so.3

```
rm ld-linux-armhf.so.3 cp /etc/arm/4.9.4/arm-linux-gnueabihf/libc/lib/ld-linux-armhf.so.3 ./lib/
```

# 完善根文件系统

### 创建必要的目录

sudo mkdir dev etc lib mnt proc sys tmp var

拷贝源码目录下的启动配置文件

```
busybox-1.35.0/examples/bootfloppy/etc ./etc -r
```

![https://nyarukov.gitee.io/cdn/images/linux/busybox/16-42-11.png](https://nyarukov.gitee.io/cdn/images/linux/busybox/16-42-11.png)

# 根文件系统的打包

每个芯片烧录需要的根文件系统镜像文件格式都不相同，这个需要先了解原厂提供的rootfs的格式才能完成打包(这里需要注意编译用的交叉编译器只能对应该交叉编译器支持的芯片使用这里的文件系统

## 启动开发板

![https://nyarukov.gitee.io/cdn/images/linux/busybox/18-13-30.png](https://nyarukov.gitee.io/cdn/images/linux/busybox/18-13-30.png)

根文件系统启动正常
