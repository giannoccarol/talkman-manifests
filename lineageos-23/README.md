# cityman — LineageOS 23.2 (Android 16) manifest

Status (2026-10-30): the full build completes (`m bacon` produces the flashable
zip); **no Android 16 build has booted yet**.
The kernel branch was boot-tested on Android 13 (eBPF: 24/24 programs load).
Do not flash anything from these branches expecting a working phone.

## Build

```
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs --depth=1 -g default,-darwin,-mips
mkdir -p .repo/local_manifests
cp cityman_a16_manifest.xml .repo/local_manifests/
repo sync -c -j8 --no-clone-bundle --no-tags
/path/to/this/dir/apply-patches.sh "$PWD"
source build/envsetup.sh
export WITH_ADB_INSECURE=true   # adb and logcat on the first boots
lunch lineage_cityman-bp4a-userdebug
m bacon
```

`soong_build` needs about 17-20 GB of memory on this tree. On smaller hosts,
`patches/build/soong/0001` lets you bound its Go heap: export
`SOONG_GOMEMLIMIT=9GiB SOONG_GOGC=50` before `m`.

## Why these projects

LineageOS-UL stops at 21.0 (Android 14), so Android 16 is built on plain
LineageOS 23.2 plus:

| Project | Why |
|---|---|
| Ultra-Legacy-Hippeastrum/legacy_support_patches | framework/native/system patches for legacy kernels and GPUs (GLES RenderEngine, cgroup v1, backpressure, ...) |
| Ultra-Legacy-Hippeastrum/android_device_qcom_sepolicy (lineage-23.2-legacy) | legacy QCOM sepolicy |
| davigamer987/hardware_qcom_{display,audio,media} (lineage-23.0-caf-msm8994) | msm8994 CAF HALs ported to Android 16 for the OnePlus 2 |
| LineageOS-UL/android_hardware_qcom_audio (lineage-21.0) | generic `audio.primary.msm8992`, the HAL the cityman 18.1/20 ROMs use |
| LineageOS-UL/android_hardware_qcom_gps (lineage-21.0) | last tree with the msm8994 GPS HAL |

## Our patches (`patches/`)

| Patch | Why |
|---|---|
| build/soong/0001 | `SOONG_GOMEMLIMIT`/`SOONG_GOGC` reach `soong_build` (memory-bounded analysis) |
| build/soong/0002 | `rustc_wrapper.sh` strips the build root only at the start of a path; with the tree at `/src` it also cut `/src/` inside paths and every build rebuilt aconfig and its outputs |
| hardware/qcom-caf/msm8994/display/0001 | define `PAGE_SIZE` when bionic does not (`__BIONIC_NO_PAGE_SIZE_MACRO`) |
| hardware/qcom-caf/bt/0001 | libbt-vendor with `USE_OLD_WCNSS_FILTER` (the msm8994 `wcnss_filter` blob uses unprefixed `wc_transport.*`) and without BT NV address support, as on Android 13 |
| frameworks/base/0001 | app compaction off by default: the 3.10 kernel has no `process_madvise` |
| frameworks/base/0002 | cached processes can be killed right after boot (3 GB device) |

## Credits

LineageOS; Ultra-Legacy-Hippeastrum (acroreiser / Yaroslav Zviezda,
Lost-Entrepreneur439, and the authors of the patches they carry: phh,
Adithya R, Roman Stratiienko, davigamer987); davigamer987 for the
msm8994 HALs and the OnePlus 2 Android 16 tree used as reference;
GuaiYiHu / xiaomi-classic-dev for the leo/libra kernel backports;
LineageOS-UL; Android4Lumia950 (djokcho, EpicLPer, j0sh1x and the
community) for the Lumia 950/950 XL port this work builds on.
