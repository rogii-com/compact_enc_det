EXECUTE_PROCESS(
    COMMAND
    ${CMAKE_COMMAND} -E time ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_LIST_DIR}/cmake/package/build_x86.cmake"
)
