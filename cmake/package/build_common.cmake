if (NOT DEFINED ARCH)
    message(FATAL_ERROR "Assert: ARCH = ${ARCH}")
endif ()

set(
    BUILD
    0
)

if (DEFINED ENV{BUILD_NUMBER})
    set(
        BUILD
        $ENV{BUILD_NUMBER}
    )
endif ()

set(
    TAG
    ""
)

if (DEFINED ENV{TAG})
    set(
        TAG
        "$ENV{TAG}"
    )
else ()
    find_package(
        Git
    )

    IF (Git_FOUND)
        execute_process(
            COMMAND
            ${GIT_EXECUTABLE} rev-parse --short HEAD
            OUTPUT_VARIABLE
            TAG
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        set(
            TAG
            "_g${TAG}"
        )
    else ()
        message(FATAL_ERROR "Can't find git executable (required for package version generation)!")
    endif ()
endif ()

# Read package version
include(
    "${CMAKE_CURRENT_LIST_DIR}/../version/Version.cmake"
)

set(
    PROJECT_SOURCE_ROOT_DIR
    ${CMAKE_SOURCE_DIR}
)

set(
    PACKAGE_NAME
    "compact_enc_det-${PACKAGE_VERSION}-${ARCH}-${BUILD}${TAG}"
)

set(
    BASE_BUILD_PATH
    "${CMAKE_CURRENT_LIST_DIR}/../../build/${ARCH}"
)

if (NOT "${CMAKE_HOST_UNIX}")
    if ("${ARCH}" STREQUAL "x86")
        set(ARCH_PARAMETER "Win32")
    else ()
        set(ARCH_PARAMETER "x64")
    endif ()
endif ()

execute_process(
    COMMAND
    ${CMAKE_COMMAND} -S . -B "${BASE_BUILD_PATH}" -A "${ARCH_PARAMETER}"
)

execute_process(
    COMMAND
    ${CMAKE_COMMAND} --build ${BASE_BUILD_PATH} --target ced --config RelWithDebInfo
)

execute_process(
    COMMAND
    ${CMAKE_COMMAND} --build ${BASE_BUILD_PATH} --target ced --config Debug
)

set(
    OUTPUT_PACKAGE_DIR
    "${CMAKE_CURRENT_LIST_DIR}/../../build"
)

set(PACKAGE_PATH ${BASE_BUILD_PATH}/${PACKAGE_NAME})

# Copy artifacts direct to package
file(
    COPY
    "${CMAKE_CURRENT_LIST_DIR}/package.cmake"
    DESTINATION
    ${PACKAGE_PATH}
    )

file(
    COPY
    "${CMAKE_CURRENT_LIST_DIR}/../../compact_enc_det/compact_enc_det.h"
    DESTINATION
    ${PACKAGE_PATH}/include/compact_enc_det
)

file(GLOB ENCODING_HEADERS "${CMAKE_CURRENT_LIST_DIR}/../../util/encodings/encodings*.h")
file(
    COPY
    ${ENCODING_HEADERS}
    DESTINATION
    ${PACKAGE_PATH}/include/util/encodings
)

file(GLOB LANGUAGES_HEADERS "${CMAKE_CURRENT_LIST_DIR}/../../util/languages/languages*.h")
file(
    COPY
    ${LANGUAGES_HEADERS}
    DESTINATION
    ${PACKAGE_PATH}/include/util/languages
)

file(
    COPY
    "${BASE_BUILD_PATH}/lib"
    DESTINATION
    ${PACKAGE_PATH}
)

# Make an archive
execute_process(
    COMMAND
    ${CMAKE_COMMAND} -E tar cf "${OUTPUT_PACKAGE_DIR}/${PACKAGE_NAME}.7z" --format=7zip -- "${PACKAGE_PATH}"
    WORKING_DIRECTORY ${BASE_BUILD_PATH}
)