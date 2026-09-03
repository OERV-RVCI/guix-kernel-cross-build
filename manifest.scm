(use-modules
 (gnu packages cross-toolchain)
 (guix profiles)
 (guix packages)
 (gnu packages linux)
 (gnu packages version-control)
 (gnu packages rsync)
 (gnu packages curl)
 (gnu packages nss))

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
              kmod))))
