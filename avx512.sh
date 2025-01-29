#!/usr/bin/env bash

# Set strict error handling
set -euo pipefail

# Text formatting
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)

# Function to print section headers
print_header() {
    echo "${BOLD}${BLUE}$1${NORMAL}"
    echo "${BLUE}$(printf '=%.0s' {1..50})${NORMAL}"
}

# Function to print yes/no with color
print_feature() {
    local feature=$1
    local status=$2
    if [ "$status" -eq 1 ]; then
        echo "${feature}: ${GREEN}Yes${NORMAL}"
    else
        echo "${feature}: ${RED}No${NORMAL}"
    fi
}

# Detect OS
OS="$(uname)"
print_header "System Information"
echo "Operating System: $OS"
echo "CPU Model:"

case $OS in
    "Linux")
        lscpu | grep "Model name" | cut -d: -f2 | xargs | awk '!seen[$0]++'  # Remove duplicates
        ;;
    "Darwin")
        sysctl -n machdep.cpu.brand_string
        ;;
    *)
        echo "Unsupported operating system"
        exit 1
        ;;
esac

# Function to check CPU flags
get_cpu_flags() {
    case $OS in
        "Linux")
            lscpu | grep "^Flags:" | cut -d: -f2
            ;;
        "Darwin")
            sysctl -n machdep.cpu.features machdep.cpu.leaf7_features | tr '[:upper:]' '[:lower:]' | tr '\n' ' '
            ;;
    esac
}

# Get CPU flags
CPU_FLAGS=$(get_cpu_flags)

# Function to check if flag exists
has_flag() {
    echo "$CPU_FLAGS" | grep -q "$1" && echo 1 || echo 0
}

print_header "AVX512 Foundation and Essential Extensions"

# Check AVX512F (Foundation) - base feature
AVX512F=$(has_flag "avx512f")
print_feature "AVX512F (Foundation)" $AVX512F

if [ "$AVX512F" -eq 1 ]; then
    print_header "AVX512 Core Extensions"

    # Core extensions
    print_feature "AVX512BW  (Byte and Word Instructions)" $(has_flag "avx512bw")
    print_feature "AVX512CD  (Conflict Detection)" $(has_flag "avx512cd")
    print_feature "AVX512DQ  (Doubleword and Quadword)" $(has_flag "avx512dq")
    print_feature "AVX512VL  (Vector Length Extensions)" $(has_flag "avx512vl")

    print_header "AVX512 Advanced Extensions"

    # Integer and floating-point extensions
    print_feature "AVX512_IFMA    (Integer Fused Multiply-Add)" $(has_flag "avx512ifma")
    print_feature "AVX512_VBMI    (Vector Byte Manipulation)" $(has_flag "avx512_vbmi")
    print_feature "AVX512_VBMI2   (Vector Byte Manipulation 2)" $(has_flag "avx512_vbmi2")
    print_feature "AVX512_VNNI    (Vector Neural Network Instructions)" $(has_flag "avx512_vnni")
    print_feature "AVX512_BITALG  (Bit Algorithms)" $(has_flag "avx512_bitalg")
    print_feature "AVX512_VPOPCNTDQ (Population Count)" $(has_flag "avx512_vpopcntdq")
    print_feature "AVX512_BF16    (BFloat16 Instructions)" $(has_flag "avx512_bf16")
    print_feature "AVX512_FP16    (16-bit Floating-Point)" $(has_flag "avx512_fp16")

    print_header "AVX512 Server Extensions"

    # Server-specific features (Knights Landing/Xeon Phi)
    print_feature "AVX512_4FMAPS  (4-iterations Fused Multiply-Add)" $(has_flag "avx512_4fmaps")
    print_feature "AVX512_4VNNIW  (4-iteration Vector NN Instructions)" $(has_flag "avx512_4vnniw")
    print_feature "AVX512_PF      (Prefetch Instructions)" $(has_flag "avx512pf")
    print_feature "AVX512_ER      (Exponential and Reciprocal)" $(has_flag "avx512er")

    print_header "AVX512 Additional Instructions"

    # Newer extensions and specialized instructions
    print_feature "AVX512_VP2INTERSECT (Vector Pair Intersection)" $(has_flag "avx512_vp2intersect")
    print_feature "VAES              (Vector AES)" $(has_flag "vaes")
    print_feature "GFNI              (Galois Field Instructions)" $(has_flag "gfni")
    print_feature "VPCLMULQDQ        (Vector CLMUL)" $(has_flag "vpclmulqdq")
    print_feature "AVX512_VBMI2      (Vector Byte Manipulation 2)" $(has_flag "avx512_vbmi2")

    print_header "Latest AVX512 Extensions"

    # Latest additions to AVX512
    print_feature "AVX512_BF16_AMX   (Advanced Matrix Extensions)" $(has_flag "amx_bf16")
    print_feature "AVX512_FP16_AMX   (FP16 AMX)" $(has_flag "amx_fp16")
    print_feature "AVX512_INT8_AMX   (INT8 AMX)" $(has_flag "amx_int8")
    print_feature "AVX512_TILE       (Tile operations)" $(has_flag "amx_tile")

else
    echo "${RED}${BOLD}No AVX512 support detected on this CPU${NORMAL}"
fi

# Additional information
print_header "Base Vector Extensions"
print_feature "AVX              (Advanced Vector Extensions)" $(has_flag "avx")
print_feature "AVX2             (Advanced Vector Extensions 2)" $(has_flag "avx2")
print_feature "FMA              (Fused Multiply-Add)" $(has_flag "fma")
print_feature "F16C             (16-bit FP Conversion)" $(has_flag "f16c")

# Check if running in a virtual machine
print_header "Virtualization Check"
case $OS in
    "Linux")
        if systemd-detect-virt -q 2>/dev/null || grep -q "^flags.*hypervisor" /proc/cpuinfo; then
            echo "${BOLD}${RED}Running in a virtual machine${NORMAL}"
            echo "Note: Some CPU features might be hidden by the hypervisor"
        else
            echo "${BOLD}${GREEN}Running on physical hardware${NORMAL}"
        fi
        ;;
    "Darwin")
        if system_profiler SPHardwareDataType | grep -q "Virtual Machine"; then
            echo "${BOLD}${RED}Running in a virtual machine${NORMAL}"
            echo "Note: Some CPU features might be hidden by the hypervisor"
        else
            echo "${BOLD}${GREEN}Running on physical hardware${NORMAL}"
        fi
        ;;
esac

# Show all flags for verification
print_header "All CPU Flags (Raw)"
echo "$CPU_FLAGS" | fold -w 70 | sed 's/^/  /'

exit 0
