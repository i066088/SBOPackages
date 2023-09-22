set(CEF_VERSION 115.3.11)
set(CHROME_VERSION 115.0.5790.114)

# Not useful for CEF
#set(VCPKG_BUILD_SHARED_LIBS OFF)
#set(VCPKG_BUILD_STATIC_LIBS ON)

# build CEF as a static library
set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_download_distfile(
    archive
    URLS "https://cef-builds.spotifycdn.com/cef_binary_${CEF_VERSION}%2Bga61da9b%2Bchromium-${CHROME_VERSION}_windows64.tar.bz2"
    FILENAME "cef_binary_${CEF_VERSION}_chromium-${CHROME_VERSION}_windows64.tar.bz2"
    SHA512 fe3db52b196e30210e7a4b32c931f1ec85547c682af345d753382b0305c224e4829585e2c1bd793ead15cee18ffe1c881f450a01596f9f3f7cff3431d464e148
)

# Apply use-md.patch to enable Multi-threaded DLL (/MD)
vcpkg_extract_source_archive(
    src
    ARCHIVE "${archive}"
    PATCHES
        use-md.patch
)

# CEF_RUNTIME_LIBRARY_FLAG="/MD" funcionally equivalent to use-md.patch
vcpkg_configure_cmake(
    SOURCE_PATH "${src}"
    GENERATOR "Visual Studio 17 2022"
    OPTIONS
        -DUSE_SANDBOX=OFF
        -DCEF_RUNTIME_LIBRARY_FLAG="/MD"
)

vcpkg_build_cmake()
# vcpkg_install_cmake()


# cef_sandbox.lib is compiled with Multi-threaded (/MT). So exclude cef_sandbox.lib and turn off USE_SANDBOX by -DUSE_SANDBOX=OFF
file(GLOB CEF_LIB_FILES_RELEASE "${src}/Release/*.lib")
file(GLOB CEF_BIN_FILES_RELEASE "${src}/Release/*")

file(GLOB CEF_LIB_FILES_DEBUG "${src}/Debug/*.lib")
file(GLOB CEF_BIN_FILES_DEBUG "${src}/Debug/*")

file(INSTALL ${CEF_BIN_FILES_RELEASE} DESTINATION ${CURRENT_PACKAGES_DIR}/bin PATTERN "*.lib" EXCLUDE)
file(INSTALL  ${CEF_LIB_FILES_RELEASE} DESTINATION ${CURRENT_PACKAGES_DIR}/lib PATTERN "cef_sandbox.lib" EXCLUDE)
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libcef_dll_wrapper/Release/libcef_dll_wrapper.lib" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libcef_dll_wrapper/Release/libcef_dll_wrapper.pdb" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${CEF_BIN_FILES_DEBUG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin PATTERN "*.lib" EXCLUDE)
file(INSTALL  ${CEF_LIB_FILES_DEBUG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib PATTERN "cef_sandbox.lib" EXCLUDE)
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libcef_dll_wrapper/Debug/libcef_dll_wrapper.lib" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libcef_dll_wrapper/Debug/libcef_dll_wrapper.pdb" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

# cef requires an extra include folder
file(INSTALL "${src}/include/" DESTINATION ${CURRENT_PACKAGES_DIR}/include/include)
file(INSTALL "${src}/LICENSE.txt" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL "${src}/Resources/" DESTINATION ${CURRENT_PACKAGES_DIR}/data)
