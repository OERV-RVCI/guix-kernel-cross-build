# guix-kernel-cross-build

用 [Guix](https://guix.gnu.org/) `guix pack` 制作的**内核交叉编译容器**。

本仓库只做一件事:通过 GitHub Actions 流水线(`.github/workflows/guix-pack.yml`)
在 CI 上用 `guix pack -f docker` 把 `manifest.scm` 描述的 riscv64 交叉工具链
打包成 Docker 镜像并推送到 registry。**容器内不含 guix-daemon,不能作为通用
Guix 环境,只能用于内核构建**。

## 镜像内容

| 内容 | 来源 |
|---|---|
| `riscv64-linux-gnu-` 交叉工具链(gcc、binutils 等) | `linux-libre` 的 development manifest,`#:target "riscv64-linux-gnu"` |
| `git` / `rsync` / `curl` / `nss-certs` / `kmod` / `cpio` | `manifest.scm` 显式声明 |
| `/usr/bin/guix-cross-build` | 仓库根的 `guix-cross-build` 脚本,构建时经 `computed-file` 嵌入镜像 |

## 镜像构建与发布

流水线由**纯 git tag push** 触发,无手动 dispatch:

| 推送的 tag | 发布到 `hub.oepkgs.net/oerv-ci/guix-kernel-cross-build` 的 tag |
|---|---|
| `v*` | `<tag>` + `release` |
| `dev-v*` | `<tag>` + `dev` |

注意:**流水线不会产出 `latest` tag**,拉取时请使用具体版本 tag 或 `release` / `dev`。

流水线步骤:CI 上从零安装 Guix → `guix time-machine --commit=<DEFAULT_GUIX_COMMIT>`
拉取固定版本的 Guix → `guix pack -f docker` 打包 manifest → `docker load` +
retag → 推送 registry。构建完全靠官方 substitute,不依赖任何 base image。

## 使用

容器是 x86_64 的,内核为纯交叉编译(宿主机架构无关,无需 qemu-user):

```bash
docker run -ti -v /your/data/path:/srv/guix_result \
    hub.oepkgs.net/oerv-ci/guix-kernel-cross-build:release bash
```

进入容器后,传入 commit 或 PR 的 URL 运行构建:

```bash
# 指定已合并的 commit
guix-cross-build https://github.com/RVCK-Project/rvck/commit/32c7ba2136024ee1563416607e3265ccbee6a55e > test.log 2>&1

# 指定未合并的 PR
guix-cross-build https://github.com/RVCK-Project/rvck-olk/pull/103 > test.log 2>&1
```

### 支持的仓库

| 仓库 | defconfig |
|---|---|
| https://github.com/RVCK-Project/rvck 及其同名 fork(`xxx/rvck`) | `rvck_defconfig` |
| https://github.com/RVCK-Project/rvck-olk 及其同名 fork(`xxx/rvck-olk`) | `openeuler_defconfig` |
| https://github.com/openRuyi-Project/linux 及其同名 fork(`xxx/linux`) | `defconfig` |

仓库名取 URL 路径的第二段,由它决定使用的 defconfig;除上述外仓库名为
`openruyi-linux` 的仓库也可用(`defconfig`)。

## 构建产物

构建完毕后产物存放在 `/srv/guix_result/<commit>/` 下:

```
Image           # riscv64 内核镜像
vmlinux         # 带 debug 信息的 ELF
lib/modules/    # 安装后的内核模块
lib/dtb/        # 设备树(保留 vendor 子目录)
<kver>.tgz      # 模块压缩包,目标机 `tar -xzf <kver>.tgz -C /` 直接落到标准路径
```

## 仓库结构

```
manifest.scm                    # guix pack 的 manifest:交叉工具链 + 构建依赖 + 嵌入脚本
guix-cross-build                # 构建入口脚本:clone → defconfig → make → 收集产物
.github/workflows/guix-pack.yml # CI 流水线:guix pack → docker load → push registry
```
