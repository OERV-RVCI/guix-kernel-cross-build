# guix-cross-build
guix交叉编译构建内核
|支持的仓库|仓库地址|
|---|---|
|rvck|https://github.com/RVCK-Project/rvck|
|rvck-olk|https://github.com/RVCK-Project/rvck-olk|

> 也支持仓库名为 rvck、rvck-olk 的fork仓库： https://github.com/xxx/rvck 、https://github.com/xxx/rvck-olk
## 使用
因为会生成initramfs，所以需要准备qemu-user环境   
oe x86环境下需要访问目录触发挂载
```
# ls -alh /proc/sys/fs/binfmt_misc
```
在x86环境下qemu-user安装
```
# docker run --privileged --rm tonistiigi/binfmt --install all
```
测试qemu-user环境
```
#  docker run --rm --platform linux/riscv64 alpine uname -a
Linux 49d78a4ac4f1 6.6.0-78.0.0.83.oe2403sp1.x86_64 #1 SMP Wed Feb 19 18:06:41 CST 2025 riscv64 Linux
```
运行构建容器，需要挂载本地目录进容器
```
# docker run -ti --privileged -v /your/data/path:/srv/guix_result hub.oepkgs.net/oerv-ci/guix-kernel-cross-build:latest  bash
```

进入容器后，查看guix进程
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
6.6.101.tgz  Image  Image.md5sum  Module.symvers  System.map  initramfs.img  initramfs.img.md5sum  lib  share
```