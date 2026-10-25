# cityman — LineageOS 20 (Android 13) manifest skeleton

Status: skeleton only. Not synced against, not built. Full plan:
`ANDROID13-CITYMAN-PLAN.md` in the project folder.

## Base

```
repo init -u https://github.com/LineageOS-UL/android.git -b lineage-20.0 --git-lfs --depth=1
mkdir -p .repo/local_manifests
cp cityman_a13_manifest.xml .repo/local_manifests/
repo sync -c -j4 --no-clone-bundle --no-tags
```

LineageOS 20 upstream dropped msm8994 HALs and expects eBPF and a 4.x
kernel. LineageOS-UL ("ultra legacy") keeps forks of the projects that
break on old kernels:

| Project | UL change relevant to a 3.10 kernel |
|---|---|
| system/bpf | "Support no-bpf usecase" (bpfloader exits cleanly) |
| system/netd | "Support no-bpf usecase", no abort on cgroup/bpf setup failure |
| packages/modules/Connectivity | no UID deletion from BpfMap on BPF-less kernels, legacy traffic indicators |
| system/core | cgroup v1 freezer (revert of the v2 switch), fastbootd legacy hacks |
| packages/modules/adb | "adb always offline" fix for old FunctionFS |
| device/qcom/sepolicy-legacy | lineage-20.0-legacy policy |
| hardware/qcom-caf/msm8994/display | lineage-20.0-caf-msm8994 |

## Projects that change against `lineageos-18.1/cityman_a11_manifest.xml`

| Path | 18.1 | 20 |
|---|---|---|
| device/msft/cityman | lineage-18.1-cityman | lineage-20-cityman (local branch, not pushed) |
| kernel/mmo/msm8994 | lineage-18.1-cityman-camera | lineage-20-cityman (21.0 + next merge, local, not pushed) |
| vendor/msft/cityman | lineage-18.1-cityman | lineage-20-cityman (local branch, not pushed) |
| hardware/qcom/display | Android4Lumia950 lineage-18.1 | removed; replaced by hardware/qcom-caf/msm8994/display (UL) |
| hardware/qcom-caf/msm8994/audio | (not used) | LineageOS lineage-18.1-caf-msm8994 |
| hardware/qcom-caf/msm8994/media | (not used) | LineageOS lineage-18.1-caf-msm8994 |
| hardware/sony/timekeep | lineage-18.1 (local manifest) | lineage-20, already in the UL manifest |
| packages/modules/NetworkStack | Android4Lumia950 "11" | UL default |
| packages/apps/Updater | Android4Lumia950 lineage-18.1 | LineageOS default |
| vendor/apn | pinned commit | no such project in 20.0 |
| packages/apps/GoogleCamera | lakgarg master | dropped for now |

## Patches from `../lineageos-20-ul/` (libra LineageOS 20)

Candidates, to check one by one after the first sync:

- 0001 permissive user build: only while sepolicy is permissive.
- 0006 wpa_supplicant fix (qcwcn lib printf types): **required**, the
  qcwcn driver_cmd_nl80211.c fails with -Wformat on u64. Applied by
  `android-cityman/build-env-l20/apply-patches.sh` after a sync.
- 0002/0003/0004/0005/0008/0010/0011: libra product choices, not needed
  for a first boot.
- `../lineageos-19.1/0007-remove_android_system_warn.diff`: hides the
  "internal problem with your device" dialog that `Build.isBuildConsistent()`
  shows when system and vendor fingerprints differ; check that it still
  applies to frameworks/base 20.
