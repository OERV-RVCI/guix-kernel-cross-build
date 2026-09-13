(use-modules
 (gnu packages cross-toolchain)
 (guix profiles)
 (guix packages)
 (guix gexp)
 (guix build-system trivial)
 (gnu packages linux)
 (gnu packages version-control)
 (gnu packages rsync)
 (gnu packages curl)
 (gnu packages nss)
 (gnu packages cpio))

;; 把仓库根的 guix-cross-build 脚本嵌进镜像,落到 /bin/guix-cross-build。
;; local-file 相对路径要求 guix pack 在仓库根目录运行(workflow 已切 cd)。
(define guix-cross-build-pkg
  (package
    (name "guix-cross-build")
    (version "0")
    (source #f)
    (build-system trivial-build-system)
    (arguments
     '(#:modules ((guix build utils))
       #:builder
       (begin
         (use-modules (guix build utils))
         (let* ((out (assoc-ref %outputs "out"))
                (bin (string-append out "/bin")))
           (mkdir-p bin)
           (let ((script (local-file "guix-cross-build" "guix-cross-build-script")))
             (copy-file script (string-append bin "/guix-cross-build"))
             (chmod (string-append bin "/guix-cross-build") #o755))))))))

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
              cpio
              guix-cross-build-pkg))))
