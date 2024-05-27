---
title: "Linux_stty的使用"
date: 2024-05-27T23:23:36+08:00
# weight: 1
# aliases: ["/first"]
tags: ["linux"]
author: "nyaruko"
showToc: true
TocOpen: true
draft: false
hidemeta: false
comments: false
description: "Desc Text."
disableHLJS: true #
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


### 使用 `stty` 命令设置串口参数

`stty` 命令用于配置和显示终端设备的设置，特别是串口设置。在串口通信中，正确的参数配置对于数据传输的准确性和效率至关重要。

#### 1. 显示串口参数信息
要查看指定串口设备的当前配置参数，可以使用以下命令：
```bash
stty -F /dev/ttyACM0 -a
```
该命令显示所有与指定串口 `/dev/ttyACM0` 相关的当前配置参数。

#### 2. 设置串口参数信息
可以使用 `stty` 命令配置串口的各种参数，如速率、数据位、校验位等。

- 设置为7位数据位，无校验，1位停止位，无回显：
    ```bash
    stty -F /dev/ttyACM0 speed 115200 cs7 -parenb -cstopb -echo
    ```
    - `speed 115200`：设置波特率为115200。
    - `cs7`：设置数据位为7。
    - `-parenb`：禁用校验位。
    - `-cstopb`：设置1位停止位。
    - `-echo`：禁用回显。

- 设置为8位数据位，1位停止位，偶数校验位：
    ```bash
    stty -F /dev/ttyACM0 speed 115200 cs8 -cstopb parenb -parodd
    ```
    - `cs8`：设置数据位为8。
    - `parenb`：启用校验位。
    - `-parodd`：设置为偶数校验。

#### 3. 串口发送数据
要向指定串口发送数据，可以使用以下命令：
```bash
echo "1234456" > /dev/ttyACM0
```
该命令将字符串 "1234456" 发送到 `/dev/ttyACM0` 设备。

#### 4. 显示串口接收数据
可以在后台显示从串口接收的数据：
```bash
cat /dev/ttyACM0 &
```
该命令在后台实时显示从 `/dev/ttyACM0` 接收到的数据。

#### 5. 其他 `stty` 命令功能

- **清除串口缓冲区**：
    ```bash
    stty -F /dev/ttyACM0 flush
    ```
    清除输入和输出缓冲区的数据。

- **设置特定的控制字符**：
    ```bash
    stty -F /dev/ttyACM0 intr ^C susp ^Z
    ```
    设置中断字符为 Ctrl+C，挂起字符为 Ctrl+Z。

- **显示串口状态**：
    ```bash
    stty -F /dev/ttyACM0 status
    ```
    显示串口的当前状态信息。

- **等待并读取一行数据**：
    ```bash
    stty -F /dev/ttyACM0 raw; cat /dev/ttyACM0; stty -F /dev/ttyACM0 -raw
    ```
    在原始模式下读取数据，并在读取后恢复到正常模式。

- **监视串口输入**：
    ```bash
    stty -F /dev/ttyACM0 -icanon min 1 time 0 && cat /dev/ttyACM0
    ```
    设置串口为非规范模式，立即读取字符。

- **设置串口为非阻塞模式**：
    ```bash
    stty -F /dev/ttyACM0 -icanon -echo -echoe -echok -echoctl -echoke -icrnl -ixon -ixoff -ixon
    ```
    禁用规范模式和各种回显，禁用输入控制字符映射。

- **设置输出换行模式**：
    ```bash
    stty -F /dev/ttyACM0 opost -onlcr
    ```
    启用输出处理，但禁用换行映射。

- **设置输入换行模式**：
    ```bash
    stty -F /dev/ttyACM0 -icrnl
    ```
    禁用输入回车转换为换行。

- **设置流控制**：
    ```bash
    stty -F /dev/ttyACM0 -crtscts
    ```
    禁用硬件流控制。

- **设置输入速率和输出速率**：
    ```bash
    stty -F /dev/ttyACM0 ispeed 9600 ospeed 9600
    ```
    分别设置输入和输出的波特率为9600。
=