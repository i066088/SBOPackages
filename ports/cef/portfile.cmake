set(CEF_VERSION 107.1.9)
set(CHROME_VERSION 107.0.5304.110)

# Not useful for CEF
#set(VCPKG_BUILD_SHARED_LIBS OFF)
#set(VCPKG_BUILD_STATIC_LIBS ON)

# build CEF as a static library
set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_download_distfile(
    archive
    URLS "https://cef-builds.spotifycdn.com/cef_binary_${CEF_VERSION}%2Bg1f0a21a%2Bchromium-${CHROME_VERSION}_windows64.tar.bz2"
    FILENAME "cef_binary_${CEF_VERSION}_chromium-${CHROME_VERSION}_windows64.tar.bz2"
    SHA512 81e4ce641cbf44f35bc09ff471d1893b9ce037ce27f399af8898be429b745a8e0f5fa8cfa203965f55b74d335dec94f7be4b9a73b0f0fbe71b5fbab0f8116e49
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
