# guix-cross-build
guix交叉编译构建内核
|支持的仓库|仓库地址|
|---|---|
|rvck|https://github.com/RVCK-Project/rvck|
|rvck-olk|https://github.com/RVCK-Project/rvck-olk/|

## 使用
在x86环境下启动容器
```
# docker run -ti --privileged -v /your/data/path:/srv/guix_result hub.oepkgs.net/oerv-ci/guix-kernel-cross-build:latest  bash
```

查看guix进程
```
# ps
    PID TTY          TIME CMD
      1 pts/0    00:00:00 bash
      8 pts/0    00:00:00 guix-start.sh
     76 pts/0    00:00:00 guix-daemon
     79 pts/0    00:00:00 ps
```

指定已合并的commit,运行guix构建
```
# guix-cross-build https://github.com/RVCK-Project/rvck/commit/32c7ba2136024ee1563416607e3265ccbee6a55e > test.log 2>&1
```
指定为合并的PR,运行guix构建
```
# guix-cross-build https://github.com/RVCK-Project/rvck-olk/pull/103  > test.log 2>&1
```
构建完毕后，*/srv/guix_result/*目录下会存放着这次构建的产物
```
# ls /srv/guix_result/
32c7ba2136024ee1563416607e3265ccbee6a55e
# ls /srv/guix_result/32c7ba2136024ee1563416607e3265ccbee6a55e/
6.6.101.tgz  Image  Module.symvers  System.map  initramfs.img  lib  share
```