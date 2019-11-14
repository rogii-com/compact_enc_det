if(TARGET compact_enc_det)
    return()
endif()

add_library(
    compact_enc_det
    STATIC
    IMPORTED
)

set_target_properties(
    compact_enc_det
    PROPERTIES
        IMPORTED_LOCATION             "${CMAKE_CURRENT_LIST_DIR}/lib/ced${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG       "${CMAKE_CURRENT_LIST_DIR}/lib/cedd${CMAKE_STATIC_LIBRARY_SUFFIX}"
        INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_LIST_DIR}/include"
)
