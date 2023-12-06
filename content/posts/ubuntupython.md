---
title: "Ubuntu 升级Python 3.6 到 Python 3.9"
date: 2022-12-28T11:30:03+00:00
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

# Ubuntu升级 Python 3.6 到 Python 3.9

## 安装必要的软件包

首先，你需要安装一些必要的软件包，以便在你的系统中编译 Python。输入以下命令来安装这些软件包：

```
Copy code
sudo apt-get install build-essential libbz2-dev libssl-dev libreadline-dev libsqlite3-dev
```

## 下载 Python 3.9 的源代码

接下来，你需要下载 Python 3.9 的源代码。你可以使用以下命令来下载 Python 3.9 的最新版本：

```
Copy code
wget https://www.python.org/ftp/python/3.9.4/Python-3.9.4.tar.xz
```



## 解压 Python 3.9 的源代码

下载完成后，你需要解压 Python 3.9 的源代码。输入以下命令来解压源代码：

```
Copy code
tar xvJf Python-3.9.4.tar.xz
```



## 编译和安装 Python 3.9

现在，你可以编译并安装 Python 3.9。首先，进入 Python 3.9 的源代码目录，然后运行以下命令来编译 Python 3.9：

```
Copy codecd Python-3.9.4
./configure
make
```

这可能需要几分钟的时间。

## 安装 Python 3.9

编译完成后，你可以使用以下命令来安装 Python 3.9：

```
Copy code
sudo make install
```

这会将 Python 3.9 安装到你的系统中。

## 更新 Python 链接

最后，你可能需要更新 Python 链接，以便你的系统能够找到新安装的 Python 3.9。输入以下命令来更新 Python 链接：

```
Copy code
sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python3.9 1
```

这样就可以将你的系统中的Python 3.6 升级到 Python 3.9 了。

注意：在执行上述步骤之前，你可能需要备份你的系统，以便在发生意外情况时能够恢复。此外，在升级 Python 时，你可能需要重新安装一些 Python 库和工具，因为它们可能与新版本的 Python 不兼容。
