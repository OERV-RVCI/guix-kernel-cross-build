(use-modules
 (gnu packages cross-toolchain)
 (guix profiles)
 (guix packages)
 (guix gexp)
 (gnu packages linux)
 (gnu packages version-control)
 (gnu packages rsync)
 (gnu packages curl)
 (gnu packages nss)
 (gnu packages cpio))

;; 把仓库根的 guix-cross-build 脚本嵌进镜像:由 computed-file 拷一份
;; 到 <store>/.../bin/guix-cross-build 并 chmod +x,workflow 再用
;; -S 把它软链到 /usr/bin/guix-cross-build,这样不需要在仓库里
;; chmod,也不必把脚本伪装成 package(免去 license/synopsis/description
;; 等元数据)。local-file 相对路径要求 guix pack 在仓库根目录运行
;; (workflow 已切 cd)。
(define guix-cross-build-bin
  (computed-file "guix-cross-build"
    (with-imported-modules '((guix build utils))
      #~(begin
          (use-modules (guix build utils))
          (let* ((bin (string-append #$output "/bin"))
                 (script (local-file "guix-cross-build" "guix-cross-build-src")))
            (mkdir-p bin)
            (copy-file script (string-append bin "/guix-cross-build"))
            (chmod (string-append bin "/guix-cross-build") #o755))))))

(concatenate-manifests
 (list (package->development-manifest
        (package (inherit linux-libre)
                 (native-inputs
                  (modify-inputs native-inputs
                    (delete "zstd"))))
        #:target "riscv64-linux-gnu")
       (packages->manifest
        (list git
              rsync
              curl
              nss-certs
              kmod
              cpio))
       (manifest
        (list (manifest-entry
                (name "guix-cross-build")
                (version "0")
                (item guix-cross-build-bin))))))
