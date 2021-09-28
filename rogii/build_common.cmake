if(
    NOT DEFINED ROOT
    OR NOT DEFINED ARCH
)
    message(
        FATAL_ERROR
        "Assert: ROOT = ${ROOT}; ARCH = ${ARCH}"
    )
endif()

set(
    BUILD
    0
)

if(DEFINED ENV{BUILD_NUMBER})
    set(
        BUILD
        $ENV{BUILD_NUMBER}
    )
endif()

set(
    TAG
    ""
)

if(DEFINED ENV{TAG})
    set(
        TAG
        "$ENV{TAG}"
    )
else()
    find_package(
        Git
    )

    if(Git_FOUND)
        execute_process(
            COMMAND
                ${GIT_EXECUTABLE} rev-parse --short HEAD
            OUTPUT_VARIABLE
                TAG
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        set(
            TAG
            "_${TAG}"
        )
    endif()
endif()

include(
    "${CMAKE_CURRENT_LIST_DIR}/version.cmake"
)

set(
    BUILD_PATH
    "${CMAKE_CURRENT_LIST_DIR}/../build"
)

set(
    PACKAGE_NAME
    "compact_enc_det-${ROGII_PKG_VERSION}-${ARCH}-${BUILD}${TAG}"
)

set(
    CMAKE_INSTALL_PREFIX
    ${ROOT}/${PACKAGE_NAME}
)

set(
    DEBUG_PATH
    "${BUILD_PATH}/debug"
)

set(
    RELEASE_PATH
    "${BUILD_PATH}/release"
)

file(
    MAKE_DIRECTORY
    "${DEBUG_PATH}"
)
file(
    MAKE_DIRECTORY
    "${RELEASE_PATH}"
)

execute_process(
    COMMAND
    ${CMAKE_COMMAND} -S . -B "${DEBUG_PATH}" -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_DEBUG_POSTFIX=d
)

execute_process(
    COMMAND
    ${CMAKE_COMMAND} --build "${DEBUG_PATH}" --target ced
)

execute_process(
    COMMAND
    ${CMAKE_COMMAND} -S . -B "${RELEASE_PATH}" -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo
)

execute_process(
    COMMAND
    ${CMAKE_COMMAND} --build "${RELEASE_PATH}" --target ced
)


file(
    COPY
        "${CMAKE_CURRENT_LIST_DIR}/package.cmake"
    DESTINATION
        ${CMAKE_INSTALL_PREFIX}
)
# Copy artifacts direct to package
file(
    COPY
    "${CMAKE_CURRENT_LIST_DIR}/package.cmake"
    DESTINATION
    ${CMAKE_INSTALL_PREFIX}
)

file(
    COPY
    "${CMAKE_CURRENT_LIST_DIR}/../compact_enc_det/compact_enc_det.h"
    DESTINATION
    ${CMAKE_INSTALL_PREFIX}/include/compact_enc_det
)

file(GLOB ENCODING_HEADERS "${CMAKE_CURRENT_LIST_DIR}/../util/encodings/encodings*.h")

file(
    COPY
    ${ENCODING_HEADERS}
    DESTINATION
    ${CMAKE_INSTALL_PREFIX}/include/util/encodings
)

file(GLOB LANGUAGES_HEADERS "${CMAKE_CURRENT_LIST_DIR}/../util/languages/languages*.h")

file(
    COPY
    ${LANGUAGES_HEADERS}
    DESTINATION
    ${CMAKE_INSTALL_PREFIX}/include/util/languages
)

file(
    COPY
    "${DEBUG_PATH}/lib"
    DESTINATION
    ${CMAKE_INSTALL_PREFIX}
)

file(
    COPY
    "${RELEASE_PATH}/lib"
    DESTINATION
    ${CMAKE_INSTALL_PREFIX}
)

file(
    REMOVE_RECURSE
    "${BUILD_PATH}"
)

execute_process(
    COMMAND
        "${CMAKE_COMMAND}" -E tar cf "${PACKAGE_NAME}.7z" --format=7zip -- "${PACKAGE_NAME}"
    WORKING_DIRECTORY
        "${ROOT}"
)

