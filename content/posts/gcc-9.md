---
title: "ubuntu 22.04 安装gcc-9、gcc-7、gcc-5"
date: 2023-1-03T11:30:03+00:00
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

# 安装gcc-9

```
sudo apt-get install gcc-9 -y 
```

# 安装gcc-7

## 添加镜像

```
sudo vim /etc/apt/sources.list deb [arch=amd64] http://archive.ubuntu.com/ubuntu focal main universe 
```

## 更新镜像

```
sudo apt-get update 
```

## 指定版本安装

```
sudo apt-get -y install gcc-7 g++-7 
```

# 配置优先级

## 配置版本的优先级

```
#配置gcc版本的优先级 update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 70 update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 50 update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 30 update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 20 #配置g++版本的优先级 update-alternatives  --install /usr/bin/g++ g++ /usr/bin/g++-5 70 update-alternatives  --install /usr/bin/g++ g++ /usr/bin/g++-7 50 update-alternatives  --install /usr/bin/g++ g++ /usr/bin/g++-9 30 update-alternatives  --install /usr/bin/g++ g++ /usr/bin/g++-12 20 
```

## 切换gcc版本

## 查看

# 安装gcc-5

## 安装依赖

```
sudo apt install ncurses-dev sudo apt install bison sudo apt install flex sudo apt install build-essential 
```

还有一个依赖项**libisl15**需要安装，使用*apt install libisl15*无法安装，使用dpkg安装：

```
wget http://archive.ubuntu.com/ubuntu/pool/universe/i/isl-0.18/libisl15_0.18-4_amd64.deb sudo dpkg -i libisl15_0.18-4_amd64.deb 
```

## 安装gcc-5

创建一个文件夹g++ -5用于存放这8个deb文件，wget下载这8个deb文件，然后用dpkg安装：

# 切换与gcc-7相同
